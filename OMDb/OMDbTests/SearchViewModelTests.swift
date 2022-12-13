//
//  SearchViewModelTests.swift
//  OMDbTests
//
//  Created by Andrew Mathias on 13/12/2022.
//

import XCTest
@testable import OMDb

final class SearchViewModelTests: XCTestCase {
    
    // test createQueryParams
    private func testQueryParams() {
        let vm = buildViewModel()
       
        vm.titleInput = "Interstellar"
        vm.sendAction(.newSearch)
        
        let expectedQuery: [Query] = [
            Query(key: "s", value: "Interstellar"),
            Query(key: "page", value: 1)
        ]
        
        for i in 0...expectedQuery.count {
            let expectedObj: Query = expectedQuery[i]
            let vmObj: Query = vm.queryParams[i]
            XCTAssertEqual(expectedObj.key, vmObj.key)
            
            if vmObj.key == "s" {
                XCTAssertEqual(expectedObj.value as? String, vmObj.value as? String)
            }
            
            if vmObj.key == "page" {
                XCTAssertEqual(expectedObj.value as? Int, vmObj.value as? Int)
            }
        }
    }
    
    // TODO: - test is list full logic.. if per page is less show button
    
    private func buildViewModel() -> SearchViewModel {
        let apiClient = APIClient(urlSession: .shared)
        return SearchViewModel(apiClient: apiClient)
    }
    
}
