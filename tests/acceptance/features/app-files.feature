Feature: app-files

  Scenario: viewing a favorite file in its folder shows the correct sidebar view
    Given I am logged in
    And I create a new folder named "other"
    And I mark "other" as favorite
    And I mark "welcome.txt" as favorite
    And I see that "other" is marked as favorite
    And I see that "welcome.txt" is marked as favorite
    And I open the "Favorites" section
    And I open the details view for "other"
    And I see that the details view is open
    And I see that the file name shown in the details view is "other"
    When I view "welcome.txt" in folder
    Then I see that the current section is "All files"
    And I see that the details view is open
    And I see that the file name shown in the details view is "welcome.txt"
    When I open the details view for "other"
    And I see that the file name shown in the details view is "other"


  Scenario: viewing a favorite file in its folder does not prevent opening the details view in "All files" section
    Given I am logged in
    And I mark "welcome.txt" as favorite
    And I see that "welcome.txt" is marked as favorite
    And I open the "Favorites" section
    And I open the details view for "welcome.txt"
    And I see that the details view is open
    And I view "welcome.txt" in folder
    And I see that the current section is "All files"
    When I open the details view for "welcome.txt"
    Then I see that the details view is open

  Scenario: show recent files
    Given I am logged in
    And I create a new folder named "Folder just created"
    When I open the "Recent" section
    Then I see that the current section is "Recent"
    Then I see that the file list contains a file named "Folder just created"

  Scenario: show recent files for a second time
    Given I am logged in
    And I open the "Recent" section
    And I see that the current section is "Recent"
    And I open the "All files" section
    And I see that the current section is "All files"
    And I create a new folder named "Folder just created"
    When I open the "Recent" section
    Then I see that the current section is "Recent"
    Then I see that the file list contains a file named "Folder just created"

  Scenario: show favorites
    Given I am logged in
    And I mark "welcome.txt" as favorite
    When I open the "Favorites" section
    Then I see that the current section is "Favorites"
    Then I see that the file list contains a file named "welcome.txt"

  Scenario: show favorites for a second time
    Given I am logged in
    And I open the "Favorites" section
    And I see that the current section is "Favorites"
    And I open the "All files" section
    And I see that the current section is "All files"
    And I mark "welcome.txt" as favorite
    When I open the "Favorites" section
    Then I see that the current section is "Favorites"
    Then I see that the file list contains a file named "welcome.txt"

  Scenario: show shares
    Given I am logged in
    And I share the link for "welcome.txt"
    When I open the "Shares" section
    Then I see that the current section is "Shares"
    Then I see that the file list contains a file named "welcome.txt"

  Scenario: show shares for a second time
    Given I am logged in
    And I open the "Shares" section
    And I see that the current section is "Shares"
    And I open the "All files" section
    And I see that the current section is "All files"
    And I share the link for "welcome.txt"
    When I open the "Shares" section
    Then I see that the current section is "Shares"
    Then I see that the file list contains a file named "welcome.txt"

  Scenario: show deleted files
    Given I am logged in
    And I delete "welcome.txt"
    When I open the "Deleted files" section
    Then I see that the current section is "Deleted files"
    Then I see that the file list contains a file named "welcome.txt"

  Scenario: show deleted files for a second time
    Given I am logged in
    And I open the "Deleted files" section
    And I see that the current section is "Deleted files"
    And I open the "All files" section
    And I see that the current section is "All files"
    And I delete "welcome.txt"
    When I open the "Deleted files" section
    Then I see that the current section is "Deleted files"
    Then I see that the file list contains a file named "welcome.txt"

  Scenario: rename a file with the details view open
    Given I am logged in
    And I open the details view for "welcome.txt"
    When I rename "welcome.txt" to "farewell.txt"
    Then I see that the file list contains a file named "farewell.txt"
    And I see that the file name shown in the details view is "farewell.txt"

  Scenario: open the menu in a public shared link
    Given I act as John
    And I am logged in
    And I share the link for "welcome.txt"
    And I write down the shared link
    When I act as Jane
    And I visit the shared link I wrote down
    And I see that the current page is the shared link I wrote down
    And I open the Share menu
    Then I see that the Share menu is shown

  Scenario: creation is not possible by default in a public shared folder
    Given I act as John
    And I am logged in
    And I create a new folder named "Shared folder"
    # To share the link the "Share" inline action has to be clicked but, as the
    # details view is opened automatically when the folder is created, clicking
    # on the inline action could fail if it is covered by the details view due
    # to its opening animation. Instead of ensuring that the animations of the
    # contents and the details view have both finished it is easier to close the
    # details view and wait until it is closed before continuing.
    And I close the details view
    And I see that the details view is closed
    And I share the link for "Shared folder"
    And I write down the shared link
    When I act as Jane
    And I visit the shared link I wrote down
    And I see that the current page is the shared link I wrote down
    And I see that the file list is eventually loaded
    Then I see that it is not possible to create new files

  Scenario: create folder in a public editable shared folder
    Given I act as John
    And I am logged in
    And I create a new folder named "Editable shared folder"
    # To share the link the "Share" inline action has to be clicked but, as the
    # details view is opened automatically when the folder is created, clicking
    # on the inline action could fail if it is covered by the details view due
    # to its opening animation. Instead of ensuring that the animations of the
    # contents and the details view have both finished it is easier to close the
    # details view and wait until it is closed before continuing.
    And I close the details view
    And I see that the details view is closed
    And I share the link for "Editable shared folder"
    And I set the shared link as editable
    And I write down the shared link
    When I act as Jane
    And I visit the shared link I wrote down
    And I see that the current page is the shared link I wrote down
    And I create a new folder named "Subfolder"
    Then I see that the file list contains a file named "Subfolder"

  Scenario: owner sees folder created in the public page of an editable shared folder
    Given I act as John
    And I am logged in
    And I create a new folder named "Editable shared folder"
    # To share the link the "Share" inline action has to be clicked but, as the
    # details view is opened automatically when the folder is created, clicking
    # on the inline action could fail if it is covered by the details view due
    # to its opening animation. Instead of ensuring that the animations of the
    # contents and the details view have both finished it is easier to close the
    # details view and wait until it is closed before continuing.
    And I close the details view
    And I see that the details view is closed
    And I share the link for "Editable shared folder"
    And I set the shared link as editable
    And I write down the shared link
    And I act as Jane
    And I visit the shared link I wrote down
    And I see that the current page is the shared link I wrote down
    And I create a new folder named "Subfolder"
    And I see that the file list contains a file named "Subfolder"
    When I act as John
    And I enter in the folder named "Editable shared folder"
    Then I see that the file list contains a file named "Subfolder"

  Scenario: set a password to a shared link
    Given I am logged in
    And I share the link for "welcome.txt"
    When I protect the shared link with the password "abcdef"
    Then I see that the working icon for password protect is shown
    And I see that the working icon for password protect is eventually not shown
    And I see that the link share is password protected
    # As Talk is not enabled in the acceptance tests of the server the checkbox
    # is never shown.
    And I see that the checkbox to protect the password of the link share by Talk is not shown

  Scenario: access a shared link protected by password with a valid password
    Given I act as John
    And I am logged in
    And I share the link for "welcome.txt" protected by the password "abcdef"
    And I write down the shared link
    When I act as Jane
    And I visit the shared link I wrote down
    And I see that the current page is the Authenticate page for the shared link I wrote down
    And I authenticate with password "abcdef"
    Then I see that the current page is the shared link I wrote down
    And I see that the shared file preview shows the text "Welcome to your Nextcloud account!"

  Scenario: access a shared link protected by password with an invalid password
    Given I act as John
    And I am logged in
    And I share the link for "welcome.txt" protected by the password "abcdef"
    And I write down the shared link
    When I act as Jane
    And I visit the shared link I wrote down
    And I authenticate with password "fedcba"
    Then I see that the current page is the Authenticate page for the shared link I wrote down
    And I see that a wrong password for the shared file message is shown

  Scenario: access a direct download shared link protected by password with a valid password
    Given I act as John
    And I am logged in
    And I share the link for "welcome.txt" protected by the password "abcdef"
    And I write down the shared link
    When I act as Jane
    And I visit the direct download shared link I wrote down
    And I see that the current page is the Authenticate page for the direct download shared link I wrote down
    And I authenticate with password "abcdef"
    # download starts no page redirection
    And I see that the current page is the Authenticate page for the direct download shared link I wrote down

  Scenario: show the input field for tags in the details view
    Given I am logged in
    And I open the details view for "welcome.txt"
    And I see that the details view is open
    When I open the input field for tags in the details view
    Then I see that the input field for tags in the details view is shown

  Scenario: show the input field for tags in the details view after the sharing tab has loaded
    Given I am logged in
    And I open the details view for "welcome.txt"
   And I see that the details view is open
    And I open the "Sharing" tab in the details view
    And I see that the "Sharing" tab in the details view is eventually loaded
    When I open the input field for tags in the details view
    Then I see that the input field for tags in the details view is shown

  Scenario: create tags using the Administration settings
    Given I am logged in as the admin
    And I visit the settings page
    And I open the "Workflow" section
    # The "create" button does nothing before JavaScript was initialized, and
    # the only way to detect that is waiting for the button to select tags to be
    # shown.
    And I see that the button to select tags is shown
    When I create the tag "tag1" in the settings
    Then I see that the dropdown for tags in the settings eventually contains the tag "tag1"

  Scenario: add tags using the dropdown in the details view
    Given I am logged in as the admin
    And I visit the settings page
    And I open the "Workflow" section
    # The "create" button does nothing before JavaScript was initialized, and
    # the only way to detect that is waiting for the button to select tags to be
    # shown.
    And I see that the button to select tags is shown
    And I create the tag "tag1" in the settings
    And I create the tag "tag2" in the settings
    And I create the tag "tag3" in the settings
    And I create the tag "tag4" in the settings
    And I see that the dropdown for tags in the settings eventually contains the tag "tag1"
    And I see that the dropdown for tags in the settings eventually contains the tag "tag2"
    And I see that the dropdown for tags in the settings eventually contains the tag "tag3"
    And I see that the dropdown for tags in the settings eventually contains the tag "tag4"
    And I log out
    And I am logged in
    And I open the details view for "welcome.txt"
    And I open the input field for tags in the details view
    # When the input field is opened the dropdown is also opened automatically.
    When I check the tag "tag2" in the dropdown for tags in the details view
    And I check the tag "tag4" in the dropdown for tags in the details view
    Then I see that the tag "tag2" in the dropdown for tags in the details view is checked
    And I see that the tag "tag4" in the dropdown for tags in the details view is checked
    And I see that the input field for tags in the details view contains the tag "tag2"
    And I see that the input field for tags in the details view contains the tag "tag4"

  Scenario: remove tags using the dropdown in the details view
    Given I am logged in as the admin
    And I visit the settings page
    And I open the "Workflow" section
    # The "create" button does nothing before JavaScript was initialized, and
    # the only way to detect that is waiting for the button to select tags to be
    # shown.
    And I see that the button to select tags is shown
    And I create the tag "tag1" in the settings
    And I create the tag "tag2" in the settings
    And I create the tag "tag3" in the settings
    And I create the tag "tag4" in the settings
    And I see that the dropdown for tags in the settings eventually contains the tag "tag1"
    And I see that the dropdown for tags in the settings eventually contains the tag "tag2"
    And I see that the dropdown for tags in the settings eventually contains the tag "tag3"
    And I see that the dropdown for tags in the settings eventually contains the tag "tag4"
    And I log out
    And I am logged in
    And I open the details view for "welcome.txt"
    And I open the input field for tags in the details view
    # When the input field is opened the dropdown is also opened automatically.
    And I check the tag "tag2" in the dropdown for tags in the details view
    And I check the tag "tag4" in the dropdown for tags in the details view
    And I check the tag "tag3" in the dropdown for tags in the details view
    When I uncheck the tag "tag2" in the dropdown for tags in the details view
    And I uncheck the tag "tag4" in the dropdown for tags in the details view
    Then I see that the tag "tag2" in the dropdown for tags in the details view is not checked
    And I see that the tag "tag4" in the dropdown for tags in the details view is not checked
    And I see that the tag "tag3" in the dropdown for tags in the details view is checked
    And I see that the input field for tags in the details view does not contain the tag "tag2"
    And I see that the input field for tags in the details view does not contain the tag "tag4"
    And I see that the input field for tags in the details view contains the tag "tag3"

  Scenario: marking a file as favorite causes the file list to be sorted again
    Given I am logged in
    And I create a new folder named "A name alphabetically lower than welcome.txt"
    And I see that "A name alphabetically lower than welcome.txt" precedes "welcome.txt" in the file list
    # To mark the file as favorite the file actions menu has to be shown but, as
    # the details view is opened automatically when the folder is created,
    # clicking on the menu trigger could fail if it is covered by the details
    # view due to its opening animation. Instead of ensuring that the animations
    # of the contents and the details view have both finished it is easier to
    # close the details view and wait until it is closed before continuing.
    And I close the details view
    And I see that the details view is closed
    When I mark "welcome.txt" as favorite
    Then I see that "welcome.txt" is marked as favorite
    And I see that "welcome.txt" precedes "A name alphabetically lower than welcome.txt" in the file list

  Scenario: unmarking a file as favorite causes the file list to be sorted again
    Given I am logged in
    And I create a new folder named "A name alphabetically lower than welcome.txt"
    And I see that "A name alphabetically lower than welcome.txt" precedes "welcome.txt" in the file list
    # To mark the file as favorite the file actions menu has to be shown but, as
    # the details view is opened automatically when the folder is created,
    # clicking on the menu trigger could fail if it is covered by the details
    # view due to its opening animation. Instead of ensuring that the animations
    # of the contents and the details view have both finished it is easier to
    # close the details view and wait until it is closed before continuing.
    And I close the details view
    And I see that the details view is closed
    And I mark "welcome.txt" as favorite
    And I see that "welcome.txt" is marked as favorite
    And I see that "welcome.txt" precedes "A name alphabetically lower than welcome.txt" in the file list
    When I unmark "welcome.txt" as favorite
    Then I see that "welcome.txt" is not marked as favorite
    And I see that "A name alphabetically lower than welcome.txt" precedes "welcome.txt" in the file list
