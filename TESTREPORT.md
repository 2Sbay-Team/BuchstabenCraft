# WorldLearning Fix – Prüfergebnisse

## Tatsächlich ausgeführt
- JSON-Aufgabenbank: 945 eindeutige IDs; alle 15 Modi genau einer der drei Lernwelten zugeordnet.
- Alle Multiple-Choice-Antworten sind unter den Optionen, ohne Duplikate.
- 379/379 Audio-Manifestpfade existieren.
- Python-Simulation der Auswahllogik: je 100.000 Auswahlen in drei Welten; jeder verfügbare Eintrag erreicht.
- ZIP-Integrität geprüft.

## Behoben (Codeanalyse)
- Alle 945 Fragen sind einem Lernwelt-Menü zugeordnet.
- Aufgaben ohne Sprachclip werden nicht mehr stillschweigend ausgefiltert; stattdessen Vorlesehinweis.
- Handschrift-, Satz- und Königsbuchstaben-Aufgaben erhalten einen Modus zur manuellen Kontrolle.
- Visuelle Zählaufgaben zeigen Punkte.
- Wiederholung nach erschöpfter Ausschlussliste möglich.
- Schreibbewegungen werden nicht automatisch als richtig gewertet.

## Nicht behoben / nicht geprüft
- Godot-4-Laufzeitstart: Godot nicht installiert.
- Android APK und Xiaomi Stift-/Touch-Test.
- Bildfragen haben noch keine echten Illustrationen und werden als manuell zu betreuende Leseaufgaben markiert.
- Schulbuchgenaue Zebra-Schreibwege, vollständiger ANTON-Katalog und Sprachqualität sind nicht validiert.
- Die vorhandenen Spielmodi sind keine fertigen 3D-Obbys oder Rennen.
