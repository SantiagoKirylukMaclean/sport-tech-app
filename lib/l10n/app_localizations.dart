import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Sport Tech'**
  String get appName;

  /// No description provided for @teamSportManagement.
  ///
  /// In en, this message translates to:
  /// **'Team Sport Management'**
  String get teamSportManagement;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterEmail;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter a password'**
  String get enterPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @forgotPasswordComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Forgot password feature coming soon'**
  String get forgotPasswordComingSoon;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get invalidEmail;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @matches.
  ///
  /// In en, this message translates to:
  /// **'Matches'**
  String get matches;

  /// No description provided for @trainings.
  ///
  /// In en, this message translates to:
  /// **'Trainings'**
  String get trainings;

  /// No description provided for @championship.
  ///
  /// In en, this message translates to:
  /// **'Championship'**
  String get championship;

  /// No description provided for @evaluations.
  ///
  /// In en, this message translates to:
  /// **'Evaluations'**
  String get evaluations;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @coach.
  ///
  /// In en, this message translates to:
  /// **'Coach'**
  String get coach;

  /// No description provided for @mister.
  ///
  /// In en, this message translates to:
  /// **'Coach'**
  String get mister;

  /// No description provided for @team.
  ///
  /// In en, this message translates to:
  /// **'Team *'**
  String get team;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// No description provided for @stats.
  ///
  /// In en, this message translates to:
  /// **'Evaluations'**
  String get stats;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @superAdmin.
  ///
  /// In en, this message translates to:
  /// **'Super Admin'**
  String get superAdmin;

  /// No description provided for @coachPanel.
  ///
  /// In en, this message translates to:
  /// **'Coach Panel'**
  String get coachPanel;

  /// No description provided for @superAdminPanel.
  ///
  /// In en, this message translates to:
  /// **'Administration Panel'**
  String get superAdminPanel;

  /// No description provided for @teamsManagement.
  ///
  /// In en, this message translates to:
  /// **'Teams Management'**
  String get teamsManagement;

  /// No description provided for @clubsManagement.
  ///
  /// In en, this message translates to:
  /// **'Clubs Management'**
  String get clubsManagement;

  /// No description provided for @sportsManagement.
  ///
  /// In en, this message translates to:
  /// **'Sports Management'**
  String get sportsManagement;

  /// No description provided for @playersManagement.
  ///
  /// In en, this message translates to:
  /// **'Players Management'**
  String get playersManagement;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @toggleTheme.
  ///
  /// In en, this message translates to:
  /// **'Toggle theme'**
  String get toggleTheme;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @descriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Description is required'**
  String get descriptionRequired;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// No description provided for @invalidFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid format'**
  String get invalidFormat;

  /// No description provided for @saveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Saved successfully'**
  String get saveSuccess;

  /// No description provided for @deleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Deleted successfully'**
  String get deleteSuccess;

  /// No description provided for @updateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Updated successfully'**
  String get updateSuccess;

  /// No description provided for @createSuccess.
  ///
  /// In en, this message translates to:
  /// **'Created successfully'**
  String get createSuccess;

  /// No description provided for @saveError.
  ///
  /// In en, this message translates to:
  /// **'Error saving'**
  String get saveError;

  /// No description provided for @deleteError.
  ///
  /// In en, this message translates to:
  /// **'Error deleting'**
  String get deleteError;

  /// No description provided for @updateError.
  ///
  /// In en, this message translates to:
  /// **'Error updating'**
  String get updateError;

  /// No description provided for @createError.
  ///
  /// In en, this message translates to:
  /// **'Error creating'**
  String get createError;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this item?'**
  String get confirmDelete;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// No description provided for @appSettings.
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get appSettings;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @systemMode.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemMode;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @moreOptions.
  ///
  /// In en, this message translates to:
  /// **'More Options'**
  String get moreOptions;

  /// No description provided for @quickAccess.
  ///
  /// In en, this message translates to:
  /// **'Quick Access'**
  String get quickAccess;

  /// No description provided for @myNotes.
  ///
  /// In en, this message translates to:
  /// **'My Notes'**
  String get myNotes;

  /// No description provided for @addNote.
  ///
  /// In en, this message translates to:
  /// **'Add Note'**
  String get addNote;

  /// No description provided for @editNote.
  ///
  /// In en, this message translates to:
  /// **'Edit Note'**
  String get editNote;

  /// No description provided for @deleteNote.
  ///
  /// In en, this message translates to:
  /// **'Delete Note'**
  String get deleteNote;

  /// No description provided for @noteContent.
  ///
  /// In en, this message translates to:
  /// **'Note content'**
  String get noteContent;

  /// No description provided for @enterNoteContent.
  ///
  /// In en, this message translates to:
  /// **'Enter your note...'**
  String get enterNoteContent;

  /// No description provided for @noteContentRequired.
  ///
  /// In en, this message translates to:
  /// **'Note content is required'**
  String get noteContentRequired;

  /// No description provided for @noteCreated.
  ///
  /// In en, this message translates to:
  /// **'Note created successfully'**
  String get noteCreated;

  /// No description provided for @noteUpdated.
  ///
  /// In en, this message translates to:
  /// **'Note updated successfully'**
  String get noteUpdated;

  /// No description provided for @noteDeleted.
  ///
  /// In en, this message translates to:
  /// **'Note deleted successfully'**
  String get noteDeleted;

  /// No description provided for @confirmDeleteNote.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this note?'**
  String get confirmDeleteNote;

  /// No description provided for @noNotes.
  ///
  /// In en, this message translates to:
  /// **'No notes yet. Create your first note!'**
  String get noNotes;

  /// No description provided for @errorLoadingStatistics.
  ///
  /// In en, this message translates to:
  /// **'Error loading statistics'**
  String get errorLoadingStatistics;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noPlayerData.
  ///
  /// In en, this message translates to:
  /// **'No player data'**
  String get noPlayerData;

  /// No description provided for @noPlayerRecordFound.
  ///
  /// In en, this message translates to:
  /// **'No player record found for your account'**
  String get noPlayerRecordFound;

  /// No description provided for @players.
  ///
  /// In en, this message translates to:
  /// **'Players'**
  String get players;

  /// No description provided for @goals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get goals;

  /// No description provided for @quarters.
  ///
  /// In en, this message translates to:
  /// **'Quarters'**
  String get quarters;

  /// No description provided for @training.
  ///
  /// In en, this message translates to:
  /// **'Training'**
  String get training;

  /// No description provided for @welcomeUser.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {userName}!'**
  String welcomeUser(String userName);

  /// No description provided for @roleUser.
  ///
  /// In en, this message translates to:
  /// **'Role: {role}'**
  String roleUser(String role);

  /// No description provided for @errorLoadingTeams.
  ///
  /// In en, this message translates to:
  /// **'Error loading teams: {error}'**
  String errorLoadingTeams(String error);

  /// No description provided for @selectTeam.
  ///
  /// In en, this message translates to:
  /// **'Select Team'**
  String get selectTeam;

  /// No description provided for @activeTeam.
  ///
  /// In en, this message translates to:
  /// **'Active Team: {teamName}'**
  String activeTeam(String teamName);

  /// No description provided for @noTeamsAssigned.
  ///
  /// In en, this message translates to:
  /// **'No teams assigned.'**
  String get noTeamsAssigned;

  /// No description provided for @noTeamsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No teams available'**
  String get noTeamsAvailable;

  /// No description provided for @administrationPanel.
  ///
  /// In en, this message translates to:
  /// **'Administration Panel'**
  String get administrationPanel;

  /// No description provided for @sports.
  ///
  /// In en, this message translates to:
  /// **'Sports'**
  String get sports;

  /// No description provided for @manageSports.
  ///
  /// In en, this message translates to:
  /// **'Manage sports in the system'**
  String get manageSports;

  /// No description provided for @clubs.
  ///
  /// In en, this message translates to:
  /// **'Clubs'**
  String get clubs;

  /// No description provided for @manageClubs.
  ///
  /// In en, this message translates to:
  /// **'Manage clubs and organizations'**
  String get manageClubs;

  /// No description provided for @teams.
  ///
  /// In en, this message translates to:
  /// **'Teams'**
  String get teams;

  /// No description provided for @manageTeams.
  ///
  /// In en, this message translates to:
  /// **'Manage teams in the system'**
  String get manageTeams;

  /// No description provided for @inviteCoachAdmin.
  ///
  /// In en, this message translates to:
  /// **'Invite Coach/Admin'**
  String get inviteCoachAdmin;

  /// No description provided for @sendInvitationsCoachAdmin.
  ///
  /// In en, this message translates to:
  /// **'Send invitations to new coaches or administrators'**
  String get sendInvitationsCoachAdmin;

  /// No description provided for @invitePlayer.
  ///
  /// In en, this message translates to:
  /// **'Invite Player'**
  String get invitePlayer;

  /// No description provided for @sendInvitationsPlayers.
  ///
  /// In en, this message translates to:
  /// **'Send invitations to new players'**
  String get sendInvitationsPlayers;

  /// No description provided for @invitations.
  ///
  /// In en, this message translates to:
  /// **'Invitations'**
  String get invitations;

  /// No description provided for @viewManageInvitations.
  ///
  /// In en, this message translates to:
  /// **'View and manage pending invitations'**
  String get viewManageInvitations;

  /// No description provided for @users.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get users;

  /// No description provided for @manageUsers.
  ///
  /// In en, this message translates to:
  /// **'Manage system users'**
  String get manageUsers;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @sport.
  ///
  /// In en, this message translates to:
  /// **'Sport'**
  String get sport;

  /// No description provided for @allSports.
  ///
  /// In en, this message translates to:
  /// **'All sports'**
  String get allSports;

  /// No description provided for @club.
  ///
  /// In en, this message translates to:
  /// **'Club'**
  String get club;

  /// No description provided for @allClubs.
  ///
  /// In en, this message translates to:
  /// **'All clubs'**
  String get allClubs;

  /// No description provided for @selectSportAndClub.
  ///
  /// In en, this message translates to:
  /// **'Select a sport and a club to view teams'**
  String get selectSportAndClub;

  /// No description provided for @errorMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String errorMessage(String message);

  /// No description provided for @teamsCount.
  ///
  /// In en, this message translates to:
  /// **'Teams ({count})'**
  String teamsCount(String count);

  /// No description provided for @noTeamsFound.
  ///
  /// In en, this message translates to:
  /// **'No teams found. Create one to get started!'**
  String get noTeamsFound;

  /// No description provided for @newTeam.
  ///
  /// In en, this message translates to:
  /// **'New team'**
  String get newTeam;

  /// No description provided for @teamCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Team created successfully'**
  String get teamCreatedSuccessfully;

  /// No description provided for @assign.
  ///
  /// In en, this message translates to:
  /// **'Assign'**
  String get assign;

  /// No description provided for @deleteTeam.
  ///
  /// In en, this message translates to:
  /// **'Delete Team'**
  String get deleteTeam;

  /// No description provided for @confirmDeleteTeam.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{teamName}\"?'**
  String confirmDeleteTeam(String teamName);

  /// No description provided for @teamUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Team updated successfully'**
  String get teamUpdatedSuccessfully;

  /// No description provided for @teamDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Team deleted successfully'**
  String get teamDeletedSuccessfully;

  /// No description provided for @createdOn.
  ///
  /// In en, this message translates to:
  /// **'Created: {date}'**
  String createdOn(String date);

  /// No description provided for @createPlayerInvitation.
  ///
  /// In en, this message translates to:
  /// **'Create Player Invitation'**
  String get createPlayerInvitation;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address *'**
  String get emailAddress;

  /// No description provided for @emailAddressDescription.
  ///
  /// In en, this message translates to:
  /// **'The email address of the player you want to invite'**
  String get emailAddressDescription;

  /// No description provided for @emailIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailIsRequired;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get enterValidEmail;

  /// No description provided for @playerName.
  ///
  /// In en, this message translates to:
  /// **'Player Name *'**
  String get playerName;

  /// No description provided for @fullNamePlayer.
  ///
  /// In en, this message translates to:
  /// **'Full name of the player'**
  String get fullNamePlayer;

  /// No description provided for @playerNameIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Player name is required'**
  String get playerNameIsRequired;

  /// No description provided for @playerNameMinLength.
  ///
  /// In en, this message translates to:
  /// **'Player name must be at least 2 characters'**
  String get playerNameMinLength;

  /// No description provided for @jerseyNumber.
  ///
  /// In en, this message translates to:
  /// **'Jersey Number'**
  String get jerseyNumber;

  /// No description provided for @optionalJerseyNumber.
  ///
  /// In en, this message translates to:
  /// **'Optional jersey/shirt number'**
  String get optionalJerseyNumber;

  /// No description provided for @jerseyNumberRange.
  ///
  /// In en, this message translates to:
  /// **'Jersey number must be between 0 and 999'**
  String get jerseyNumberRange;

  /// No description provided for @noTeamsAvailableCreateFirst.
  ///
  /// In en, this message translates to:
  /// **'No teams available. Please create a team first.'**
  String get noTeamsAvailableCreateFirst;

  /// No description provided for @selectTeamForPlayer.
  ///
  /// In en, this message translates to:
  /// **'Select the team for this player'**
  String get selectTeamForPlayer;

  /// No description provided for @pleaseSelectTeam.
  ///
  /// In en, this message translates to:
  /// **'Please select a team'**
  String get pleaseSelectTeam;

  /// No description provided for @howItWorks.
  ///
  /// In en, this message translates to:
  /// **'How it works:'**
  String get howItWorks;

  /// No description provided for @invitationStep1.
  ///
  /// In en, this message translates to:
  /// **'An invitation will be sent to the player\'s email'**
  String get invitationStep1;

  /// No description provided for @invitationStep2.
  ///
  /// In en, this message translates to:
  /// **'The player can accept and set up their account'**
  String get invitationStep2;

  /// No description provided for @invitationStep3.
  ///
  /// In en, this message translates to:
  /// **'Once accepted, they\'ll have access to the app'**
  String get invitationStep3;

  /// No description provided for @resetForm.
  ///
  /// In en, this message translates to:
  /// **'Reset Form'**
  String get resetForm;

  /// No description provided for @creating.
  ///
  /// In en, this message translates to:
  /// **'Creating...'**
  String get creating;

  /// No description provided for @createInvitation.
  ///
  /// In en, this message translates to:
  /// **'Create Invitation'**
  String get createInvitation;

  /// No description provided for @failedToCreatePlayer.
  ///
  /// In en, this message translates to:
  /// **'Failed to create player: {error}'**
  String failedToCreatePlayer(String error);

  /// No description provided for @playerCreatedAndInviteSent.
  ///
  /// In en, this message translates to:
  /// **'Player {playerName} created and invitation sent successfully'**
  String playerCreatedAndInviteSent(String playerName);

  /// No description provided for @playerCreatedButInviteFailed.
  ///
  /// In en, this message translates to:
  /// **'Player created but failed to send invite: {error}'**
  String playerCreatedButInviteFailed(String error);

  /// No description provided for @sportCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Sport created successfully'**
  String get sportCreatedSuccessfully;

  /// No description provided for @sportUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Sport updated successfully'**
  String get sportUpdatedSuccessfully;

  /// No description provided for @sportDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Sport deleted successfully'**
  String get sportDeletedSuccessfully;

  /// No description provided for @clubCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Club created successfully'**
  String get clubCreatedSuccessfully;

  /// No description provided for @clubUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Club updated successfully'**
  String get clubUpdatedSuccessfully;

  /// No description provided for @clubDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Club deleted successfully'**
  String get clubDeletedSuccessfully;

  /// No description provided for @noTeamSelectedSelectFirst.
  ///
  /// In en, this message translates to:
  /// **'No team selected. Please select a team first.'**
  String get noTeamSelectedSelectFirst;

  /// No description provided for @playerEvaluations.
  ///
  /// In en, this message translates to:
  /// **'Player Evaluations'**
  String get playerEvaluations;

  /// No description provided for @selectAPlayer.
  ///
  /// In en, this message translates to:
  /// **'Select a Player'**
  String get selectAPlayer;

  /// No description provided for @selectPlayer.
  ///
  /// In en, this message translates to:
  /// **'Select a player'**
  String get selectPlayer;

  /// No description provided for @choosePlayerFromList.
  ///
  /// In en, this message translates to:
  /// **'Choose a player from the list to view their evaluations'**
  String get choosePlayerFromList;

  /// No description provided for @newEvaluation.
  ///
  /// In en, this message translates to:
  /// **'New Evaluation'**
  String get newEvaluation;

  /// No description provided for @createFirstEvaluation.
  ///
  /// In en, this message translates to:
  /// **'Create First Evaluation'**
  String get createFirstEvaluation;

  /// No description provided for @deleteEvaluation.
  ///
  /// In en, this message translates to:
  /// **'Delete evaluation'**
  String get deleteEvaluation;

  /// No description provided for @evaluationForPlayer.
  ///
  /// In en, this message translates to:
  /// **'Evaluation - {playerName}'**
  String evaluationForPlayer(String playerName);

  /// No description provided for @evaluationNotFound.
  ///
  /// In en, this message translates to:
  /// **'Evaluation not found'**
  String get evaluationNotFound;

  /// No description provided for @errorNoAuthenticatedUser.
  ///
  /// In en, this message translates to:
  /// **'Error: No authenticated user'**
  String get errorNoAuthenticatedUser;

  /// No description provided for @loadingData.
  ///
  /// In en, this message translates to:
  /// **'Loading data...'**
  String get loadingData;

  /// No description provided for @noEvaluationsYet.
  ///
  /// In en, this message translates to:
  /// **'No evaluations yet'**
  String get noEvaluationsYet;

  /// No description provided for @latestEvaluation.
  ///
  /// In en, this message translates to:
  /// **'Latest Evaluation'**
  String get latestEvaluation;

  /// No description provided for @coachNotes.
  ///
  /// In en, this message translates to:
  /// **'Coach Notes'**
  String get coachNotes;

  /// No description provided for @evaluationHistory.
  ///
  /// In en, this message translates to:
  /// **'Evaluation History'**
  String get evaluationHistory;

  /// No description provided for @evaluationsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} evaluation(s)'**
  String evaluationsCount(String count);

  /// No description provided for @noTeamSelected.
  ///
  /// In en, this message translates to:
  /// **'No Team Selected'**
  String get noTeamSelected;

  /// No description provided for @selectTeamToViewMatches.
  ///
  /// In en, this message translates to:
  /// **'Please select a team from the Dashboard to view and manage matches.'**
  String get selectTeamToViewMatches;

  /// No description provided for @noMatchesYet.
  ///
  /// In en, this message translates to:
  /// **'No matches yet'**
  String get noMatchesYet;

  /// No description provided for @createFirstMatch.
  ///
  /// In en, this message translates to:
  /// **'Create your first match using the + button'**
  String get createFirstMatch;

  /// No description provided for @manageCallUp.
  ///
  /// In en, this message translates to:
  /// **'Manage Call-Up'**
  String get manageCallUp;

  /// No description provided for @noPlayersFoundForTeam.
  ///
  /// In en, this message translates to:
  /// **'No players found for this team'**
  String get noPlayersFoundForTeam;

  /// No description provided for @jersey.
  ///
  /// In en, this message translates to:
  /// **'Jersey: {number}'**
  String jersey(String number);

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @quarterResultSaved.
  ///
  /// In en, this message translates to:
  /// **'Quarter result saved'**
  String get quarterResultSaved;

  /// No description provided for @saveResult.
  ///
  /// In en, this message translates to:
  /// **'Save Result'**
  String get saveResult;

  /// No description provided for @addGoal.
  ///
  /// In en, this message translates to:
  /// **'Add Goal'**
  String get addGoal;

  /// No description provided for @assist.
  ///
  /// In en, this message translates to:
  /// **'Assist: {assisterName}'**
  String assist(String assisterName);

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @opponentNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Opponent name is required'**
  String get opponentNameRequired;

  /// No description provided for @trainingSessionCreated.
  ///
  /// In en, this message translates to:
  /// **'Training session created'**
  String get trainingSessionCreated;

  /// No description provided for @trainingSessionUpdated.
  ///
  /// In en, this message translates to:
  /// **'Training session updated'**
  String get trainingSessionUpdated;

  /// No description provided for @deleteSession.
  ///
  /// In en, this message translates to:
  /// **'Delete Session'**
  String get deleteSession;

  /// No description provided for @confirmDeleteTrainingSession.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this training session?'**
  String get confirmDeleteTrainingSession;

  /// No description provided for @trainingSessionDeleted.
  ///
  /// In en, this message translates to:
  /// **'Training session deleted'**
  String get trainingSessionDeleted;

  /// No description provided for @pleaseSelectTeamFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select a team first'**
  String get pleaseSelectTeamFirst;

  /// No description provided for @newSession.
  ///
  /// In en, this message translates to:
  /// **'New Session'**
  String get newSession;

  /// No description provided for @manageAttendance.
  ///
  /// In en, this message translates to:
  /// **'Manage Attendance'**
  String get manageAttendance;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @sessionNotFound.
  ///
  /// In en, this message translates to:
  /// **'Session not found'**
  String get sessionNotFound;

  /// No description provided for @trainingSessions.
  ///
  /// In en, this message translates to:
  /// **'Training Sessions'**
  String get trainingSessions;

  /// No description provided for @noTrainingSessions.
  ///
  /// In en, this message translates to:
  /// **'No training sessions'**
  String get noTrainingSessions;

  /// No description provided for @noTrainingSessionsMessage.
  ///
  /// In en, this message translates to:
  /// **'Training sessions will appear here'**
  String get noTrainingSessionsMessage;

  /// No description provided for @sessionInformation.
  ///
  /// In en, this message translates to:
  /// **'Session Information'**
  String get sessionInformation;

  /// No description provided for @attendanceList.
  ///
  /// In en, this message translates to:
  /// **'Attendance List'**
  String get attendanceList;

  /// No description provided for @attendanceStatistics.
  ///
  /// In en, this message translates to:
  /// **'Attendance Statistics'**
  String get attendanceStatistics;

  /// No description provided for @totalPlayers.
  ///
  /// In en, this message translates to:
  /// **'Total Players'**
  String get totalPlayers;

  /// No description provided for @attendanceRate.
  ///
  /// In en, this message translates to:
  /// **'Attendance Rate'**
  String get attendanceRate;

  /// No description provided for @notMarked.
  ///
  /// In en, this message translates to:
  /// **'Not Marked'**
  String get notMarked;

  /// No description provided for @noPlayersInTeam.
  ///
  /// In en, this message translates to:
  /// **'No players in team'**
  String get noPlayersInTeam;

  /// No description provided for @errorLoadingPlayers.
  ///
  /// In en, this message translates to:
  /// **'Error loading players: {message}'**
  String errorLoadingPlayers(String message);

  /// No description provided for @errorUpdatingAttendance.
  ///
  /// In en, this message translates to:
  /// **'Error updating attendance: {error}'**
  String errorUpdatingAttendance(String error);

  /// No description provided for @trainingAttendance.
  ///
  /// In en, this message translates to:
  /// **'Training Attendance'**
  String get trainingAttendance;

  /// No description provided for @onTime.
  ///
  /// In en, this message translates to:
  /// **'On Time'**
  String get onTime;

  /// No description provided for @late.
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get late;

  /// No description provided for @absent.
  ///
  /// In en, this message translates to:
  /// **'Absent'**
  String get absent;

  /// No description provided for @trainingSessionDetails.
  ///
  /// In en, this message translates to:
  /// **'Training Session Details'**
  String get trainingSessionDetails;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Evaluations'**
  String get statistics;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @noTrainingAttendanceData.
  ///
  /// In en, this message translates to:
  /// **'No training attendance data available'**
  String get noTrainingAttendanceData;

  /// No description provided for @noGoalsOrAssistsData.
  ///
  /// In en, this message translates to:
  /// **'No goals or assists data available'**
  String get noGoalsOrAssistsData;

  /// No description provided for @player.
  ///
  /// In en, this message translates to:
  /// **'Player'**
  String get player;

  /// No description provided for @assists.
  ///
  /// In en, this message translates to:
  /// **'Assists'**
  String get assists;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @noMatchesPlayedYet.
  ///
  /// In en, this message translates to:
  /// **'No matches played yet'**
  String get noMatchesPlayedYet;

  /// No description provided for @matchesPlayed.
  ///
  /// In en, this message translates to:
  /// **'Matches Played'**
  String get matchesPlayed;

  /// No description provided for @winPercentage.
  ///
  /// In en, this message translates to:
  /// **'Win %'**
  String get winPercentage;

  /// No description provided for @goalDifference.
  ///
  /// In en, this message translates to:
  /// **'Goal Difference'**
  String get goalDifference;

  /// No description provided for @cleanSheets.
  ///
  /// In en, this message translates to:
  /// **'Clean Sheets'**
  String get cleanSheets;

  /// No description provided for @averageGoals.
  ///
  /// In en, this message translates to:
  /// **'Average Goals'**
  String get averageGoals;

  /// No description provided for @matchAttendance.
  ///
  /// In en, this message translates to:
  /// **'Match Attendance'**
  String get matchAttendance;

  /// No description provided for @winsDrawsLosses.
  ///
  /// In en, this message translates to:
  /// **'{wins}W - {draws}D - {losses}L'**
  String winsDrawsLosses(String wins, String draws, String losses);

  /// No description provided for @goalsForAgainst.
  ///
  /// In en, this message translates to:
  /// **'{goalsFor} for - {goalsAgainst} against'**
  String goalsForAgainst(String goalsFor, String goalsAgainst);

  /// No description provided for @percentageOfMatches.
  ///
  /// In en, this message translates to:
  /// **'{percentage}% of matches'**
  String percentageOfMatches(String percentage);

  /// No description provided for @forAgainstAverage.
  ///
  /// In en, this message translates to:
  /// **'For: {forAvg} | Against: {againstAvg}'**
  String forAgainstAverage(String forAvg, String againstAvg);

  /// No description provided for @seeDetails.
  ///
  /// In en, this message translates to:
  /// **'See details'**
  String get seeDetails;

  /// No description provided for @accountInformation.
  ///
  /// In en, this message translates to:
  /// **'Account Information'**
  String get accountInformation;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @passwordUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully'**
  String get passwordUpdatedSuccessfully;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @pleaseEnterCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your current password'**
  String get pleaseEnterCurrentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @pleaseEnterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter a new password'**
  String get pleaseEnterNewPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @pleaseConfirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your new password'**
  String get pleaseConfirmNewPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get updatePassword;

  /// No description provided for @invitePlayerDialog.
  ///
  /// In en, this message translates to:
  /// **'Invite Player'**
  String get invitePlayerDialog;

  /// No description provided for @chooseInvitationMethod.
  ///
  /// In en, this message translates to:
  /// **'Choose how to send the invitation: via email or get a shareable link.'**
  String get chooseInvitationMethod;

  /// No description provided for @sendEmail.
  ///
  /// In en, this message translates to:
  /// **'Send Email'**
  String get sendEmail;

  /// No description provided for @getLink.
  ///
  /// In en, this message translates to:
  /// **'Get Link'**
  String get getLink;

  /// No description provided for @mustBeLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'You must be logged in to send invites'**
  String get mustBeLoggedIn;

  /// No description provided for @pleaseEnterClubName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a club name'**
  String get pleaseEnterClubName;

  /// No description provided for @pleaseEnterSportName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a sport name'**
  String get pleaseEnterSportName;

  /// No description provided for @pleaseEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get pleaseEnterName;

  /// No description provided for @urlMustStartWithHttp.
  ///
  /// In en, this message translates to:
  /// **'URL must start with http:// or https://'**
  String get urlMustStartWithHttp;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter an email'**
  String get pleaseEnterEmail;

  /// No description provided for @invalidEmailFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get invalidEmailFormat;

  /// No description provided for @pleaseEnterPlayerName.
  ///
  /// In en, this message translates to:
  /// **'Please enter player name'**
  String get pleaseEnterPlayerName;

  /// No description provided for @invitationSentSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Invitation sent successfully'**
  String get invitationSentSuccessfully;

  /// No description provided for @teamPlayers.
  ///
  /// In en, this message translates to:
  /// **'Team Players'**
  String get teamPlayers;

  /// No description provided for @newEvaluationBreadcrumb.
  ///
  /// In en, this message translates to:
  /// **'New Evaluation'**
  String get newEvaluationBreadcrumb;

  /// No description provided for @detail.
  ///
  /// In en, this message translates to:
  /// **'Detail'**
  String get detail;

  /// No description provided for @lineup.
  ///
  /// In en, this message translates to:
  /// **'Lineup'**
  String get lineup;

  /// No description provided for @attendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get attendance;

  /// No description provided for @playerRole.
  ///
  /// In en, this message translates to:
  /// **'Player'**
  String get playerRole;

  /// No description provided for @coachRole.
  ///
  /// In en, this message translates to:
  /// **'Coach'**
  String get coachRole;

  /// No description provided for @adminRole.
  ///
  /// In en, this message translates to:
  /// **'Administrator'**
  String get adminRole;

  /// No description provided for @accepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get accepted;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @playerAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Player added successfully'**
  String get playerAddedSuccessfully;

  /// No description provided for @playerUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Player updated successfully'**
  String get playerUpdatedSuccessfully;

  /// No description provided for @noUrlAvailable.
  ///
  /// In en, this message translates to:
  /// **'No {label} URL available'**
  String noUrlAvailable(String label);

  /// No description provided for @urlCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'{label} URL copied to clipboard'**
  String urlCopiedToClipboard(String label);

  /// No description provided for @copyUrl.
  ///
  /// In en, this message translates to:
  /// **'Copy URL'**
  String get copyUrl;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
