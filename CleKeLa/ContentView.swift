//
//  ContentView.swift
//  CleKeLa
//
//  Created by Axel Lalaut on 29/05/2026.
//

import SwiftUI

struct Accueil: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink(destination: Note(titre: "Mon plat préféré")) {
                        Text("Mon plat préféré")
                    }
                    NavigationLink(destination: Note2()) {
                        Text("Comment avoir 1 million d'euros ?")
                    }
                } header: {
                    Text("Notes les plus récentes")
                } footer: {
                    Text("Autres notes")
                }
            }
            .environment(\.defaultMinListHeaderHeight, 100)
        }
    }
}

// Première note
struct Note: View {
    let titre: String
    var body: some View {
        Text(titre)
            .navigationTitle("Mon plat préféré")
    }
}

// Deuxième note
struct Note2: View {
    var body: some View {
        Text("Travailler dur, économiser…")
            .navigationTitle("Comment avoir 1 million d'euros")
    }
}
