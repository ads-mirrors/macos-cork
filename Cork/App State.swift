//
//  App State.swift
//  Cork
//
//  Created by David Bureš on 05.02.2023.
//

import AppKit
import CorkNotifications
import CorkShared
import Foundation
import Observation
import Defaults
import DefaultsMacros
import Dependencies
@preconcurrency import UserNotifications

/// Class that holds the global state of the app, excluding services
@Observable
final class AppState: Sendable
{
    // MARK: - Licensing

    var licensingState: LicensingState = .notBoughtOrHasNotActivatedDemo

    // MARK: - Navigation

    var navigationTargetId: UUID?

    // MARK: - Notifications

    var notificationEnabledInSystemSettings: Bool?
    var notificationAuthStatus: UNAuthorizationStatus = .notDetermined

    // MARK: - Stuff for controlling the UI in general

    var isSearchFieldFocused: Bool = false

    // MARK: - Brewfile importing and exporting

    var brewfileImportingStage: BrewfileImportStage = .importing

    var isShowingUninstallationProgressView: Bool = false
    var isShowingFatalError: Bool = false
    var fatalAlertType: DisplayableAlert?

    var isShowingConfirmationDialog: Bool = false
    var confirmationDialogType: ConfirmationDialog?

    var sheetToShow: DisplayableSheet?

    var packageTryingToBeUninstalledWithSudo: BrewPackage?

    var isShowingRemoveTapFailedAlert: Bool = false

    // MARK: - Loading of packages and taps

    var isLoadingFormulae: Bool = true
    var isLoadingCasks: Bool = true
    var isLoadingTaps: Bool = true

    var isLoadingTopPackages: Bool = false

    // MARK: - Loading errors

    var failedWhileLoadingFormulae: Bool = false
    var failedWhileLoadingCasks: Bool = false
    var failedWhileLoadingTaps: Bool = false

    var failedWhileLoadingTopPackages: Bool = false

    // MARK: - Tagging

    var corruptedPackage: String = ""

    // MARK: - Other
    @ObservableDefault(.enableExtraAnimations) @ObservationIgnored
    var enableExtraAnimations: Bool
    
    // MARK: - Custom Initializers
    nonisolated init() {
        self.licensingState = .notBoughtOrHasNotActivatedDemo
        self.navigationTargetId = nil
        self.notificationEnabledInSystemSettings = nil
        self.notificationAuthStatus = .notDetermined
        self.isSearchFieldFocused = false
        self.brewfileImportingStage = .importing
        self.isShowingUninstallationProgressView = false
        self.isShowingFatalError = false
        self.fatalAlertType = nil
        self.isShowingConfirmationDialog = false
        self.confirmationDialogType = nil
        self.sheetToShow = nil
        self.packageTryingToBeUninstalledWithSudo = nil
        self.isShowingRemoveTapFailedAlert = false
        self.isLoadingFormulae = true
        self.isLoadingCasks = true
        self.isLoadingTaps = true
        self.isLoadingTopPackages = false
        self.failedWhileLoadingFormulae = false
        self.failedWhileLoadingCasks = false
        self.failedWhileLoadingTaps = false
        self.failedWhileLoadingTopPackages = false
        self.corruptedPackage = ""
    }
}

extension AppState: DependencyKey
{
    static let liveValue: AppState = .init()
}

private extension UNUserNotificationCenter
{
    func authorizationStatus() async -> UNAuthorizationStatus
    {
        await notificationSettings().authorizationStatus
    }
}

extension AppState
{
    // MARK: - Alert Functions
    func showAlert(errorToShow: DisplayableAlert)
    {
        fatalAlertType = errorToShow

        isShowingFatalError = true
    }

    func dismissAlert()
    {
        isShowingFatalError = false

        fatalAlertType = nil
    }
}

extension AppState
{
    // MARK: - Sheet Functions
    func showSheet(ofType sheetType: DisplayableSheet)
    {
        self.sheetToShow = sheetType
    }

    func dismissSheet()
    {
        self.sheetToShow = nil
    }
}

extension AppState
{
    // MARK: - Confirmation Dialogs
    func showConfirmationDialog(ofType confirmationDialogType: ConfirmationDialog)
    {
        self.confirmationDialogType = confirmationDialogType
        self.isShowingConfirmationDialog = true
    }

    func dismissConfirmationDialog()
    {
        self.isShowingConfirmationDialog = false
        self.confirmationDialogType = nil
    }
}

extension AppState
{
    // MARK: - Notifications
    func setupNotifications() async
    {
        let notificationCenter: UNUserNotificationCenter = AppConstants.shared.notificationCenter

        let authStatus: UNAuthorizationStatus = await notificationCenter.authorizationStatus()

        switch authStatus
        {
        case .notDetermined:
            AppConstants.shared.logger.debug("Notification authorization status not determined. Will request notifications again")

            await requestNotificationAuthorization()

        case .denied:
            AppConstants.shared.logger.debug("Notifications were refused")

        case .authorized:
            AppConstants.shared.logger.debug("Notifications were authorized")

        case .provisional:
            AppConstants.shared.logger.debug("Notifications are provisional")

        case .ephemeral:
            AppConstants.shared.logger.debug("Notifications are ephemeral")

        @unknown default:
            AppConstants.shared.logger.error("Something got really fucked up about notifications setup")
        }

        notificationAuthStatus = authStatus
    }

    func requestNotificationAuthorization() async
    {
        let notificationCenter: UNUserNotificationCenter = AppConstants.shared.notificationCenter

        do
        {
            try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])

            notificationEnabledInSystemSettings = true
        }
        catch let notificationPermissionsObtainingError as NSError
        {
            AppConstants.shared.logger.error("Notification permissions obtaining error: \(notificationPermissionsObtainingError.localizedDescription, privacy: .public)\nError code: \(notificationPermissionsObtainingError.code, privacy: .public)")

            notificationEnabledInSystemSettings = false
        }
    }
}

extension AppState
{
    // MARK: - Initiating the update process from legacy contexts

    @objc func startUpdateProcessForLegacySelectors(_: NSMenuItem!)
    {
        self.showSheet(ofType: .fullUpdate)

        sendNotification(title: String(localized: "notification.upgrade-process-started"))
    }
}
