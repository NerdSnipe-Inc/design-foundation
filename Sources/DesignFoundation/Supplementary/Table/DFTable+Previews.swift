import SwiftUI

private struct Employee: Identifiable, Sendable {
    let id: Int
    let name: String
    let role: String
    let department: String
}

#Preview("DFTable — Sortable Columns") {
    let employees = [
        Employee(id: 1, name: "Alice Chen", role: "Engineer", department: "iOS"),
        Employee(id: 2, name: "Bob Kim", role: "Designer", department: "Design"),
        Employee(id: 3, name: "Carol Liu", role: "Manager", department: "iOS"),
        Employee(id: 4, name: "Dan Park", role: "Engineer", department: "Backend"),
        Employee(id: 5, name: "Emma Torres", role: "Designer", department: "Design"),
    ]
    let columns = [
        DFTableColumn<Employee>(id: "name", title: "Name") { $0.name },
        DFTableColumn<Employee>(id: "role", title: "Role") { $0.role },
        DFTableColumn<Employee>(id: "department", title: "Dept") { $0.department },
    ]

    DFTable(data: employees, columns: columns)
        .padding()
        .frame(maxHeight: 300)
}
