<!--
  - @copyright Copyright (c) 2018 John Molakvoæ <skjnldsv@protonmail.com>
  -
  - @author John Molakvoæ <skjnldsv@protonmail.com>
  -
  - @license GNU AGPL version 3 or any later version
  -
  - This program is free software: you can redistribute it and/or modify
  - it under the terms of the GNU Affero General Public License as
  - published by the Free Software Foundation, either version 3 of the
  - License, or (at your option) any later version.
  -
  - This program is distributed in the hope that it will be useful,
  - but WITHOUT ANY WARRANTY; without even the implied warranty of
  - MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  - GNU Affero General Public License for more details.
  -
  - You should have received a copy of the GNU Affero General Public License
  - along with this program. If not, see <http://www.gnu.org/licenses/>.
  -
  -->

<template>
	<div id="content" class="app-settings">
		<app-navigation :menu="menu">
			<template slot="settings-content">
				<div>
					<p>{{t('settings', 'Default quota:')}}</p>
					<multiselect :value="defaultQuota" :options="quotaOptions"
								tag-placeholder="create" :placeholder="t('settings', 'Select default quota')"
								label="label" track-by="id" class="multiselect-vue"
								:allowEmpty="false" :taggable="true"
								@tag="validateQuota" @input="setDefaultQuota">
					</multiselect>

				</div>
				<div>
					<input type="checkbox" id="showLanguages" class="checkbox" v-model="showLanguages">
					<label for="showLanguages">{{t('settings', 'Show Languages')}}</label>
				</div>
				<div>
					<input type="checkbox" id="showLastLogin" class="checkbox" v-model="showLastLogin">
					<label for="showLastLogin">{{t('settings', 'Show last login')}}</label>
				</div>
				<div>
					<input type="checkbox" id="showUserBackend" class="checkbox" v-model="showUserBackend">
					<label for="showUserBackend">{{t('settings', 'Show user backend')}}</label>
				</div>
				<div>
					<input type="checkbox" id="showStoragePath" class="checkbox" v-model="showStoragePath">
					<label for="showStoragePath">{{t('settings', 'Show storage path')}}</label>
				</div>
			</template>
		</app-navigation>
		<user-list :users="users" :showConfig="showConfig" :selectedGroup="selectedGroup" :externalActions="externalActions" :defaultQuotaValue="defaultQuota" />
	</div>
</template>

<script>
import { AppNavigation } from 'nextcloud-vue';
import userList from '../components/userList';
import Vue from 'vue';
import VueLocalStorage from 'vue-localstorage'
import Multiselect from 'vue-multiselect';
import api from '../store/api';

Vue.use(VueLocalStorage)

export default {
	name: 'Users',
	props: ['selectedGroup'],
	components: {
		AppNavigation,
		userList,
		Multiselect
	},
	beforeMount() {
		this.$store.commit('initGroups', {
			groups: this.$store.getters.getServerData.groups, 
			orderBy: this.$store.getters.getServerData.sortGroups,
			userCount: this.$store.getters.getServerData.userCount
		});
		this.$store.dispatch('getPasswordPolicyMinLength');
	},
	created() {
		// init the OCA.Settings.UserList object
		// and add the registerAction method
		Object.assign(OCA, {
			Settings: {
				UserList: {
					registerAction: this.registerAction
				}
			}
		});
	},
	data() {
		return {
			// default quota is set to unlimited
			unlimitedQuota: {id: 'none', label: t('settings', 'Unlimited')},
			// temporary value used for multiselect change
			selectedQuota: false,
			externalActions: [],
			showAddGroupEntry: false,
			loadingAddGroup: false,
			showConfig: {
				showStoragePath: false,
				showUserBackend: false,
				showLastLogin: false,
				showNewUserForm: false,
				showLanguages: false
			}
		}
	},
	methods: {
		toggleNewUserMenu() {
			this.showConfig.showNewUserForm = !this.showConfig.showNewUserForm;
			if (this.showConfig.showNewUserForm) {
				Vue.nextTick(() => {
					window.newusername.focus();
				});
			}
		},
		getLocalstorage(key) {
			// force initialization
			let localConfig = this.$localStorage.get(key);
			// if localstorage is null, fallback to original values
			this.showConfig[key] = localConfig !== null ? localConfig === 'true' : this.showConfig[key];
			return this.showConfig[key];
		},
		setLocalStorage(key, status) {
			this.showConfig[key] = status;
			this.$localStorage.set(key, status);
			return status;
		},
		removeGroup(groupid) {
			let self = this;
			// TODO migrate to a vue js confirm dialog component 
			OC.dialogs.confirm(
				t('settings', 'You are about to remove the group {group}. The users will NOT be deleted.', {group: groupid}),
				t('settings','Please confirm the group removal '),
				function (success) {
					if (success) {
						self.$store.dispatch('removeGroup', groupid);
					}
				}
			);
		},

		/**
		 * Dispatch default quota set request
		 * 
		 * @param {string|Object} quota Quota in readable format '5 GB' or Object {id: '5 GB', label: '5GB'}
		 * @returns {string}
		 */
		setDefaultQuota(quota = 'none') {
			this.$store.dispatch('setAppConfig', {
				app: 'files',
				key: 'default_quota',
				// ensure we only send the preset id
				value: quota.id ? quota.id : quota
			}).then(() => {
				if (typeof quota !== 'object') {
					quota = {id: quota, label: quota};
				}
				this.defaultQuota = quota;
			});
		},

		/**
		 * Validate quota string to make sure it's a valid human file size
		 * 
		 * @param {string} quota Quota in readable format '5 GB'
		 * @returns {Promise|boolean}
		 */
		validateQuota(quota) {
			// only used for new presets sent through @Tag
			let validQuota = OC.Util.computerFileSize(quota);
			if (validQuota === 0) {
				return this.setDefaultQuota('none');
			} else if (validQuota !== null) {
				// unify format output
				return this.setDefaultQuota(OC.Util.humanFileSize(OC.Util.computerFileSize(quota)));
			}
			// if no valid do not change
			return false;
		},

		/**
		 * Register a new action for the user menu
		 * 
		 * @param {string} icon the icon class
		 * @param {string} text the text to display
		 * @param {function} action the function to run
		 */
		registerAction(icon, text, action) {
			this.externalActions.push({
				icon: icon,
				text: text,
				action: action
			});
			return this.externalActions;
		},

		/**
		 * Create a new group
		 * 
		 * @param {Object} event The form submit event
		 */
		createGroup(event) {
			let gid = event.target[0].value;
			this.loadingAddGroup = true;
			this.$store.dispatch('addGroup', gid)
				.then(() => {
					this.showAddGroupEntry = false;
					this.loadingAddGroup = false;
				})
				.catch(() => {
					this.loadingAddGroup = false;
				});
		}
	},
	computed: {
		users() {
			return this.$store.getters.getUsers;
		},
		loading() {
			return Object.keys(this.users).length === 0;
		},
		usersOffset() {
			return this.$store.getters.getUsersOffset;
		},
		usersLimit() {
			return this.$store.getters.getUsersLimit;
		},

		// Local settings
		showLanguages: {
			get: function() {return this.getLocalstorage('showLanguages')},
			set: function(status) {
				this.setLocalStorage('showLanguages', status);
			}
		},
		showLastLogin: {
			get: function() {return this.getLocalstorage('showLastLogin')},
			set: function(status) {
				this.setLocalStorage('showLastLogin', status);
			}
		},
		showUserBackend: {
			get: function() {return this.getLocalstorage('showUserBackend')},
			set: function(status) {
				this.setLocalStorage('showUserBackend', status);
			}
		},
		showStoragePath: {
			get: function() {return this.getLocalstorage('showStoragePath')},
			set: function(status) {
				this.setLocalStorage('showStoragePath', status);
			}
		},

		userCount() {
			return this.$store.getters.getUserCount;
		},
		settings() {
			return this.$store.getters.getServerData;
		},

		// default quota
		quotaOptions() {
			// convert the preset array into objects
			let quotaPreset = this.settings.quotaPreset.reduce((acc, cur) => acc.concat({id:cur, label:cur}), []);
			// add default presets
			quotaPreset.unshift(this.unlimitedQuota);
			return quotaPreset;
		},
		// mapping saved values to objects
		defaultQuota: {
			get: function() {
				if (this.selectedQuota !== false) {
					return this.selectedQuota;
				}
				if (OC.Util.computerFileSize(this.settings.defaultQuota) > 0) {
					// if value is valid, let's map the quotaOptions or return custom quota
					return {id:this.settings.defaultQuota, label:this.settings.defaultQuota};
				}
				return this.unlimitedQuota; // unlimited
			},
			set: function(quota) {
				this.selectedQuota =  quota;
			}
			
		},

		// BUILD APP NAVIGATION MENU OBJECT
		menu() {
			// Data provided php side
			let self = this;
			let groups = this.$store.getters.getGroups;
			groups = Array.isArray(groups) ? groups : [];

			// Map groups
			groups = groups.map(group => {
				let item = {};
				item.id = group.id.replace(' ', '_');
				item.key = item.id;
				item.utils = {}

				// router link to
				item.router = {
					name: 'group',
					params: {selectedGroup: group.id}
				};

				// group name
				item.text = group.name;

				// users count
				if (group.usercount - group.disabled > 0) {
					item.utils.counter = group.usercount - group.disabled;
				}

				if (item.id !== 'admin' && item.id !== 'disabled' && this.settings.isAdmin) {
					// add delete button on real groups
					item.utils.actions = [{
						icon: 'icon-delete',
						text: t('settings', 'Remove group'),
						action: function() {
							self.removeGroup(group.id)
						}
					}];
				};
				return item;
			});

			// Every item is added on top of the array, so we're going backward
			// Groups, separator, disabled, admin, everyone

			// Add separator
			let realGroups = groups.find((group) => {return group.id !== 'disabled' && group.id !== 'admin'});
			realGroups = typeof realGroups === 'undefined' ? [] : realGroups;
			realGroups = Array.isArray(realGroups) ? realGroups : [realGroups];
			if (realGroups.length > 0) {
				let separator = {
					caption: true,
					text: t('settings', 'Groups')
				};
				groups.unshift(separator);
			}

			// Adjust admin and disabled groups
			let adminGroup = groups.find(group => group.id == 'admin');
			let disabledGroup = groups.find(group => group.id == 'disabled');

			// filter out admin and disabled
			groups = groups.filter(group => ['admin', 'disabled'].indexOf(group.id) === -1);

			if (adminGroup && adminGroup.text) {
				adminGroup.text = t('settings', 'Admins');	// rename admin group
				adminGroup.icon = 'icon-user-admin';		// set icon
				groups.unshift(adminGroup);					// add admin group if present
			}
			if (disabledGroup && disabledGroup.text) {
				disabledGroup.text = t('settings', 'Disabled users');	// rename disabled group
				disabledGroup.icon = 'icon-disabled-users';				// set icon
				if (disabledGroup.utils && disabledGroup.utils.counter > 0) {
					groups.unshift(disabledGroup);						// add disabled if not empty
				}
			}


			// Add everyone group
			let everyoneGroup = {
				id: 'everyone',
				key: 'everyone',
				icon: 'icon-contacts-dark',
				router: {name:'users'},
				text: t('settings', 'Everyone'),
			};
			// users count
			if (this.userCount > 0) {
				Vue.set(everyoneGroup, 'utils', {
					counter: this.userCount
				});
			}
			groups.unshift(everyoneGroup);

			let addGroup = {
				id: 'addgroup',
				key: 'addgroup',
				icon: 'icon-add',
				text: t('settings', 'Add group'),
				classes: this.loadingAddGroup ? 'icon-loading-small' : ''
			};
			if (this.showAddGroupEntry) {
				Vue.set(addGroup, 'edit', {
					text: t('settings', 'Add group'),
					action: this.createGroup,
					reset: function() {
						self.showAddGroupEntry = false
					}
				});
				addGroup.classes = 'editing';
			} else {
				Vue.set(addGroup, 'action', function() {
					self.showAddGroupEntry = true
				})
			}
			groups.unshift(addGroup);

			// Return
			return {
				id: 'usergrouplist',
				new: {
					id:'new-user-button',
					text: t('settings','New user'),
					icon: 'icon-add',
					action: this.toggleNewUserMenu
				},
				items: groups
			}
		},
	}
}
</script>
