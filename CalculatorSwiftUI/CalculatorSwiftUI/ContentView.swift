//
//  ContentView.swift
//  CalculatorSwiftUI
//
//  Created by Prashant Tukadiya on 20/03/21.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
       CalculatorView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(CalModel())
    }
}

enum ControlsButtons {
    case zero,one,two,three,four,five,six,seven,eight,nine
    case divde,add,minus,multi,equal
    case ac,plusMinus,percentage
    case dot
    
    var titel:String {
        switch self {
        
        case .zero:
            return "0"
        case .one:
            return "1"
        case .two:
            return "2"

        case .three:
            return "3"
            
        case .four:
            return "4"

        case .five:
            return "5"

        case .six:
            return "6"

        case .seven:
            return "7"

        case .eight:
            return "8"

        case .nine:
            return "9"

        case .divde:
            return "/"

        case .add:
            return "+"

        case .minus:
            return "-"

        case .multi:
            return "*"

        case .equal:
            return "="

        case .ac:
            return "AC"

        case .plusMinus:
            return "+/-"

        case .percentage:
            return "%"

        case .dot:
            return "."

        }
    }

}



struct CalculatorView : View {
    
    @EnvironmentObject var model:CalModel
    var controls : [[ControlsButtons]] = [ [.ac,.plusMinus,.percentage,.divde],
                                           [.seven,.eight,.nine,.multi],
                                           [.four,.five,.six,.minus],
                                           [.one,.two,.three,.add],
                                           [.zero,.dot,.equal]
                                        ]
    
    var body : some View {
        ZStack(alignment:.bottom) {
            Color.black.opacity(0.9)
            VStack {
                HStack {
                    Spacer()
                    
                    Text(model.output)
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                        .animation(.spring())
                    
                    
                }
                .padding()
                VStack (spacing:1){
                    ForEach(0..<controls.count) {index in
                        HStack(spacing:1) {
                            ForEach(0..<controls[index].count) { item in
                                let controlItem = controls[index][item]
                                
                                Button(action: {
                                    model.pushOperation(controlType: controlItem)
                                }, label: {
                                    Text(controlItem.titel)
                                        .frame(width: getWidth(type: controlItem),height:90)
                                        .font(.system(size: 30))
                                        .foregroundColor(.white)
                                        .background(getBackgroundColor(type:controlItem))

                                })
                                
                            }
                            
                        }
                        
                    }
                }
            }
            .frame(maxWidth: .infinity)
           
            
        }
        .onChange(of: model.flick) { _ in
            print(model.flick)
            
            withAnimation(.easeOut(duration: 4)) {
                let output  = model.output
                model.output = ""
                 model.output = output
            }
            

            
            
        }
    }
    
    
    func getBackgroundColor(type:ControlsButtons) -> Color {
        if type == .ac || type == .plusMinus || type == .percentage {
            return Color(UIColor.darkGray)
        } else if type == .divde || type == .multi || type == .minus || type == .add || type == .equal {
            return Color.orange
        }
        
        return Color.gray
    }
    
    func getWidth(type:ControlsButtons) -> CGFloat {
        
        if type == .zero {
            return ((UIScreen.main.bounds.width ) / 4) * 2

        }
        return (UIScreen.main.bounds.width ) / 4
    }
    
    
}

class CalModel:ObservableObject {
    @Published var output = "0"
    @Published var flick:Bool = false
    
    private var isOperationAdded :ControlsButtons? = nil
    private var isDotAdded = false
    
    private var needToClearOutputOnNextInput = false
    
    private var subject1 = ""
    private var subject2 = ""
    
    
    func pushOperation(controlType:ControlsButtons) {
        
        switch controlType {
        case .zero,.one,.two,.three,.four,.five,.six,.seven,.eight,.nine:
            //when operation was added
            if needToClearOutputOnNextInput {
                output = ""
                needToClearOutputOnNextInput.toggle()
            }
            output += controlType.titel
            output =  output.replacingOccurrences(of: "^0+", with: "", options: .regularExpression)
        case .dot:
            if isDotAdded == false {
                isDotAdded = true
                output += controlType.titel
            }
        case .ac:
            reset()
        case .add,.minus,.multi,.divde:
            self.isOperationAdded = controlType
            subject1 = output
            self.flick = true
            self.isDotAdded = false
            needToClearOutputOnNextInput = true
        case .percentage:
            output = (Double(output)! / 100).removeZerosFromEnd()
            needToClearOutputOnNextInput = true
        case .plusMinus:
            if !output.hasPrefix("-") {
                output = "-" + output
            } else {
                output = String(output.dropFirst())
            }
        case .equal:
            subject2 = output
            performOperation()
            self.flick = true

        default:
            break
        }
        
        
    }
    
    private func performOperation() {
        guard !subject1.isEmpty,!subject2.isEmpty,let operation = self.isOperationAdded  else{
            return
        }
        var number1 = Double(subject1)!
        var number2 = Double(subject2)!
        
        switch operation {
        case .add:
            print("Add")
            print("\(subject1)  + \(subject2)")
            print(number1 + number2)
            output = (number1 + number2).removeZerosFromEnd()
        case .multi:
            output = (number1 * number2).removeZerosFromEnd()
        case .divde:
            output = (number1 / number2).removeZerosFromEnd()
        case .minus:
            output = (number1 - number2).removeZerosFromEnd()
       
        
        default:
            break
            
        }
        
    }
    
    private func reset() {
        self.isOperationAdded = nil
        self.output = "0"
        self.isDotAdded = false
        subject1 = ""
        subject2 = ""
        needToClearOutputOnNextInput = false
    }
    
    
}


extension Double {
    func removeZerosFromEnd() -> String {
        let formatter = NumberFormatter()
        let number = NSNumber(value: self)
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 16 //maximum digits in Double after dot (maximum precision)
        return String(formatter.string(from: number) ?? "")
    }
}

