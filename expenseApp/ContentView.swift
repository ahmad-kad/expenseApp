//
//  ContentView.swift
//  expenseApp
//
//  Created by ahmad kaddoura on 1/17/24.
//
import Observation
import SwiftUI


struct dismissStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .buttonStyle(BorderedButtonStyle())
            .foregroundStyle(Color.white)
            .background(Color.red)
            .clipShape(Capsule())
    }
}

extension View {
    func disButton() -> some View {
        self.modifier(dismissStyle())
    }
}


@Observable
class User {
    var firstName = "John"
    var lastName = "Doe"
}

struct codeUser : Codable{
    let firstName : String
    let lastName : String
}

@Observable 
class Expenses{
    var items = [ExpenseItem](){
        didSet{
            if let encoded = try? JSONEncoder().encode(items){
                UserDefaults.standard.set(encoded,forKey: "Items")
            }
        }
    }
    
    var total: Double {
            return items.reduce(0) { $0 + $1.amount }
        }
    
    init(){
        if let savedItems = UserDefaults.standard.data(forKey: "Items"){
            if let decodedItems = try? JSONDecoder().decode([ExpenseItem].self, from: savedItems){
                items = decodedItems
                return
            }
        }
        //
        items = []
    }
}

struct ExpenseItem : Identifiable, Codable{
    var id = UUID()
    let name : String
    let type : String
    let amount : Double
}

struct codableUser: View{
    @Environment(\.dismiss) var dismiss
    @State private var user = codeUser(firstName: "Bruce", lastName: "Wayne")
    
    var body: some View{
        VStack{
            Button("Save User"){
                let encoder = JSONEncoder()
                
                if let data = try? encoder.encode(user) {
                    UserDefaults.standard.set(data,forKey:"UserData")
                }
            }
            Button("Dismiss"){
                    dismiss()
                }
                .disButton()
            
            
        }
        .navigationTitle("Codeable User")
    }
}

struct expensesApplication: View{
    @Environment(\.dismiss) var dismiss
    @State private var expenses = Expenses()
    @State private var showingAddExpense = false
    private let currencyCode = Locale.current.currency?.identifier ?? "USD"
    
    var body: some View{
        NavigationView {
                   List {
                       ForEach(expenses.items) { item in
                           HStack{
                               VStack(alignment: .leading){
                                   Text(item.name)
                                       .font(.headline)
                                   Text(item.type)
                                       .foregroundStyle(.gray)
                               }
                               Spacer()
                               Text(item.amount,format: .currency(code: currencyCode))
                           }
                       }
                       .onDelete(perform: removeItems)
                   }
                   .navigationTitle("Expense App")
                   .toolbar {
                       ToolbarItem(placement: .navigationBarTrailing) {
                           Button("Add expense", systemImage: "plus") {
                               showingAddExpense = true
                           }
                       }
                   }
                   .sheet(isPresented: $showingAddExpense){
                       AddView(expenses: expenses)
                   }
                
               }
               .navigationTitle("Expense App")
               .navigationBarTitleDisplayMode(.inline)
              
               
        Text("Total: \(expenses.total, format: .currency(code: currencyCode))")
            .font(.largeTitle)
            //.fontDesign(.default)
            //.fontWidth(.expanded)
            .fontWeight(.semibold)
            
        Button("Dismiss"){
            dismiss()
        }
        .disButton()
        
    }
    func removeItems(at offsets: IndexSet){
        expenses.items.remove(atOffsets: offsets)
    }
}

struct SecondView : View{
    @Environment(\.dismiss) var dismiss
    @State private var tapCount = UserDefaults.standard.integer(forKey: "Tap")
    
    @AppStorage("tapStorage") private var tapStorage = 0
    
    let name : String
    
    var body: some View{
        

        VStack(alignment: .leading){
            Text("Saves user data to reload on start up")
            Button("User Default - tap count: \(tapCount)"){
                tapCount += 1
                UserDefaults.standard.set(tapCount,forKey: "Tap")
            }
            .buttonStyle(.bordered)
            .backgroundStyle(.secondary)
            .foregroundColor(.white)
            
            Button("Storage - tap count: \(tapStorage)"){
                tapStorage += 1
                UserDefaults.standard.set(tapStorage,forKey: "Tap")
            }
            .buttonStyle(.borderedProminent)
            Button("Dismiss"){
                dismiss()
            }
            .disButton()
            
        }
        .padding()
        .navigationTitle("Tap Counter")
    }
    
    
}

struct showRows : View{
    @Environment(\.dismiss) var dismiss
    @State private var numbers = [Int]()
    @State private var currentNumber = 1
    
    var body: some View{
        VStack{
            NavigationStack{
                List{
                    ForEach(numbers, id: \.self) {
                        Text("R \($0)")
                    }
                    .onDelete(perform: removeRows)
                }
                Button("add num"){
                    numbers.append(currentNumber)
                    currentNumber += 1
                }
                .buttonStyle(.borderedProminent)
            }
            .toolbar{
                EditButton()
            }
            Button("Dismiss"){
                dismiss()
            }
            .disButton()
        }
        .navigationTitle("Rows")
    }
    
    func removeRows(at offsets:IndexSet){
        numbers.remove(atOffsets: offsets)
    }
}
struct ContentView: View {
    @State private var user1 = User()
    @State private var user2 = User()
    @State private var user3 = User()
    @State private var showSheet2 = false
    @State private var showRows = false
    @State private var showCodable = false
    @State private var showExpenses = false

    var body: some View {
        
        
        NavigationStack{
            LazyVGrid(columns: Array(repeating: GridItem(), count: 2), spacing: 1) {
                        Button("Show Second View") {
                            showSheet2.toggle()
                        }
                        .sheet(isPresented: $showSheet2) {
                            SecondView(name: "Second View")
                        }
                        .buttonStyle(.bordered)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                        Button("Rows View") {
                            showRows.toggle()
                        }
                        .sheet(isPresented: $showRows) {
                            expenseApp.showRows()
                        }
                        .buttonStyle(.bordered)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                        Button("Codable View") {
                            showCodable.toggle()
                        }
                        .sheet(isPresented: $showCodable) {
                            codableUser()
                        }
                        .buttonStyle(.bordered)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                        Button("ExpenseApp View") {
                            showExpenses.toggle()
                        }
                        .sheet(isPresented: $showExpenses) {
                            expensesApplication()
                        }
                        .buttonStyle(.bordered)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
        /*
            VStack {
                
                Section{
                    Text("Hello \(user1.firstName) \(user1.lastName)")
                    Text("Hello \(user2.firstName) \(user2.lastName)")
                    Text("Hello \(user3.firstName) \(user3.lastName)")
                }
                HStack{
                    TextField("First Name: ", text:$user1.firstName)
                    TextField("Last Name: ", text:$user1.lastName)
                }
                HStack{
                    TextField("First Name: ", text:$user1.firstName)
                    TextField("Last Name: ", text:$user1.lastName)
                }
                HStack{
                    TextField("First Name: ", text:$user3.firstName)
                    TextField("Last Name: ", text:$user3.lastName)
                }
                
                
            }
            .padding()
            .navigationTitle("Home")
         */
        }
    }
        
        
    
    


#Preview {
    ContentView()
}
