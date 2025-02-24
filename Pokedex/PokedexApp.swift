//
//  PokedexApp.swift
//  Pokedex
//
//  Created by Ethan TILLIER on 2/17/25.
//
//
//  PokedexApp.swift
//  Pokedex
//
//  Created by Ethan TILLIER on 2/17/25.
//

import SwiftUI
import UserNotifications

@main
struct PokedexApp: App {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false  // Stocke l'état du mode sombre
    let persistenceController = PersistenceController.shared

    init() {
        requestNotificationPermission()
        scheduleDailyNotification() // Planifier la notification quotidienne
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .preferredColorScheme(isDarkMode ? .dark : .light) // Applique le mode clair/sombre en fonction de la variable isDarkMode
                .onAppear {
                    // Vérifie si un mode a déjà été défini par l'utilisateur
                    if let savedMode = UserDefaults.standard.value(forKey: "isDarkMode") as? Bool {
                        isDarkMode = savedMode
                    }
                }
        }
    }

    // Fonction pour demander l'autorisation des notifications
    func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("✅ Permission accordée pour les notifications")
            } else {
                print("❌ Permission refusée")
            }
        }
    }

    // Fonction pour planifier une notification quotidienne
    func scheduleDailyNotification() {
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = "Rappel Pokedex"
        content.body = "N'oubliez pas de vérifier vos Pokémon aujourd'hui !"
        content.sound = .default
        
        // Définir l'heure de la notification (ex: 18h00)
        var dateComponents = DateComponents()
        dateComponents.hour = 14
        dateComponents.minute = 35
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(identifier: "dailyPokemonReminder", content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("❌ Erreur lors de la planification : \(error.localizedDescription)")
            } else {
                print("✅ Notification quotidienne programmée")
            }
        }
    }
}
