//
//  ContentView.swift
//  BetterSleep
//
//  Created by Alexander Bonney on 4/26/21.
//

import SwiftUI

struct ContentView: View {
    @State private var sleepCount = 8.0 {
        didSet {
            calculateBedTime()
        }
    }
    @State private var wakeUp = defaulfWakeUpTime {
        didSet {
            calculateBedTime()
        }
    }
    @State private var coffeeAmount = 0 {
        didSet {
            calculateBedTime()
        }
    }
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    @State private var result = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("When do you want to wake up?")) {
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                Section(header: Text("Desired amount of sleep")) {
                    Stepper(value: $sleepCount, in: 4...12, step: 0.25) {
                        Text("\(sleepCount, specifier: "%g") hours")
                    }
                }
                Section(header: Text("Daily coffee intake")) {
                /*  Stepper(value: $coffeeAmount, in: 1...20) {
                        if coffeeAmount == 1 {
                            Text("1 cup")
                        } else {
                            Text("\(coffeeAmount) cups")
                        }
                    } */
                    Picker("Choose the amount of coffee", selection: $coffeeAmount) {
                        ForEach(1..<21) { cup in
                            if cup == 1 {
                                Text("\(cup) cup")
                            } else {
                                Text("\(cup) cups")
                            }
                        }
                    }
                }
                Section(header: Text("Your ideal bedtime is…")) {
                    Text("\(calculatedBedTime)")
                }
            }
            .navigationBarTitle(Text("Sleep better"))
            .navigationBarItems(trailing:
                                    Button(action: calculateBedTime) {
                                        Text("Calculate")
                                    }
            )
            .alert(isPresented: $showingAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    static var defaulfWakeUpTime: Date {
        var components = DateComponents()
        components.hour = 4
        components.minute = 20
        return Calendar.current.date(from: components) ?? Date()
        
    }
    
    func calculateBedTime() {
        let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
        let hour = (components.hour ?? 0) * 60 * 60
        let minute = (components.minute ?? 0) * 60
        
        do {
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepCount, coffee: Double(coffeeAmount+1))
            let sleepTime = wakeUp - prediction.actualSleep
            let formatter = DateFormatter()
            formatter.timeStyle = .short

            result = formatter.string(from: sleepTime)

            // more code here
        } catch {
            // something went wrong!
            showingAlert = true
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime."
        }
    }
    
    var calculatedBedTime: String {
        result
    }
    
    let model = SleepCalculator()
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
