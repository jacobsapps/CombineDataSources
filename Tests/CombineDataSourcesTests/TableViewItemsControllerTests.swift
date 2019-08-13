import XCTest
import UIKit
@testable import CombineDataSources

struct Model: Equatable {
  var text: String
}

let dataSet1 = [
  Model(text: "test1"), Model(text: "test2"), Model(text: "test3")
]
let dataSet2 = [
  Section(header: "section header", items: [Model(text: "test model")], footer: "section footer")
]

final class TableViewItemsControllerTests: XCTestCase {
  
  func testDataSource() {
    // Make the controller
    var lastIndexPath: IndexPath? = nil
    
    let ctr = TableViewItemsController<[[Model]]>(cellIdentifier: "Cell", cellType: UITableViewCell.self) { (cell, indexPath, model) in
      lastIndexPath = indexPath
    }

    // Configure the controller
    let tableView = UITableView()
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    
    ctr.tableView = tableView
    ctr.updateCollection([dataSet1, dataSet1])
    
    // Test data source methods
    XCTAssertEqual(2, ctr.numberOfSections(in: tableView))
    XCTAssertEqual(3, ctr.tableView(tableView, numberOfRowsInSection: 0))
    
    XCTAssertNil(lastIndexPath)
    let cell = ctr.tableView(tableView, cellForRowAt: IndexPath(row: 1, section: 0))
    XCTAssertNotNil(cell)
    XCTAssertEqual(1, lastIndexPath?.row)
    
    // Test an update
    ctr.updateCollection([dataSet1])
    XCTAssertEqual(1, ctr.numberOfSections(in: tableView))
  }
  
  func testFallbackDataSource() {
    let ctr = TableViewItemsController<[[Model]]>(cellIdentifier: "Cell", cellType: UITableViewCell.self) { (cell, indexPath, model) in
      //
    }

    // Configure the controller
    let tableView = UITableView()
    ctr.tableView = tableView
    ctr.updateCollection([dataSet1])
    
    // Provide fallback data source
    class TestDataSource: NSObject, UITableViewDataSource {
      func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fatalError()
      }
      
      func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        fatalError()
      }
      
      func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "test header"
      }
      func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "test footer"
      }
    }
    
    let fallbackDataSource = TestDataSource()
    ctr.dataSource = fallbackDataSource
    
    // Test custom methods
    XCTAssertEqual(1, ctr.numberOfSections(in: tableView))
    
    // Test fallback methods
    XCTAssertEqual("test header", ctr.tableView(tableView, titleForHeaderInSection: 0))
    XCTAssertEqual("test footer", ctr.tableView(tableView, titleForFooterInSection: 0))
  }
  
  func testSections() {
    var lastModel: Model?
    let ctr = TableViewItemsController<[Section<Model>]>(cellIdentifier: "Cell", cellType: UITableViewCell.self) { (cell, indexPath, model) in
      lastModel = model
    }

    // Configure the controller
    let tableView = UITableView()
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    
    ctr.tableView = tableView
    ctr.updateCollection(dataSet2)
    
    // Test custom section methods
    XCTAssertEqual("section header", ctr.tableView(tableView, titleForHeaderInSection: 0))
    XCTAssertEqual("section footer", ctr.tableView(tableView, titleForFooterInSection: 0))
    
    XCTAssertNil(lastModel)
    let cell = ctr.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0))
    XCTAssertNotNil(cell)
    XCTAssertEqual("test model", lastModel?.text)
  }
}
