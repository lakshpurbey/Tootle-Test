//
//  NetworkInterceptorProvider.swift
//  Tootle Test
//
//  Created by Laksh Purbey on 26/09/2021.
//


import Foundation
import Apollo

class NetworkInterceptorProvider: DefaultInterceptorProvider {
    
    override func interceptors<Operation: GraphQLOperation>(for operation: Operation) -> [ApolloInterceptor] {
        var interceptors = super.interceptors(for: operation)
        interceptors.insert(TokenAddingInterceptor(), at: 0)
        return interceptors
    }
}
