//
//  ContentView.swift
//  BetterRest
//
//  Created by A M on 21.02.2023.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 8
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                RadialGradient(gradient: Gradient(colors: [.white, .blue]), center: .bottom, startRadius: 0, endRadius: 900)
                
                VStack {
                    Spacer()
                    Spacer()
                    VStack(spacing: 10) {
                        Spacer()
                        VStack {
                            Section {
                                DatePicker("enter a date", selection: $wakeUp, displayedComponents: .hourAndMinute)
                                    .labelsHidden()
                            } header: {
                                Text("When do you want to wake up")
                                    .font(.title3.bold())
                            }
                        }
                        .frame(width: 300, height: 120)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                        
                        Spacer()
                        VStack {
                            Section {
                                Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                                    .frame(width: 200)
                            } header: {
                                Text("Desired amount of sleep")
                                    .font(.title3.bold())
                            }
                        }
                        .frame(width: 300, height: 120)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                        
                        Spacer()
                        VStack {
                            Section {
                                /*Stepper(coffeeAmount == 1 ? "1 cup" : "\(coffeeAmount) cups", value: $coffeeAmount, in: 1...20)*/
                                Picker("Number of cups", selection: $coffeeAmount) {
                                    ForEach(1...20, id: \.self) { cup in
                                        Text(cup == 1 ? "1 cup" : "\(cup) cups")
                                    }
                                }
                                .accentColor(.black)
                            } header: {
                                Text("Daily amount of coffee")
                                    .font(.title3.bold())
                            }
                        }
                        .frame(width: 300, height: 120)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                        Spacer()
                    }
                    .frame(height: 300)
                    
                    Spacer()
                    
                    VStack {
                        Text("Your ideal bedtime is ")
                            .font(.title.bold())
                            .foregroundColor(.black)
                        Text("\(calculateBedTime())")
                            .font(.largeTitle.bold())
                            .foregroundColor(.green)

                         
                            
                            .navigationTitle("BetterRest")
                            /*.toolbar {
                                Button("Calculate", action: calculateBedTime)
                            }
                            .alert(alertTitle, isPresented: $showingAlert) {
                                Button("OK") {}
                            } message: {
                                Text(alertMessage)
                            }*/
                    }
                    Spacer()
                }
            }
            .ignoresSafeArea()
        }
    }

    
    func calculateBedTime() -> String {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 3600
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            alertTitle = "Your ideal bedtime is..."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
            
            return sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was an error"
            return String()
        }
        //showingAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
