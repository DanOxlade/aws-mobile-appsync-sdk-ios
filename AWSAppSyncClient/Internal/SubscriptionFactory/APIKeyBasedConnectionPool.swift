//
// Copyright 2019 Amazon.com, Inc. or its affiliates. All Rights Reserved.
// Licensed under the Amazon Software License
// http://aws.amazon.com/asl/
//

import Foundation
import AppSyncRealTimeClient

class APIKeyBasedConnectionPool: SubscriptionConnectionPool {

    private let apiKeyProvider: AWSAPIKeyAuthProvider
    var endPointToProvider: [String: ConnectionProvider]

    init(_ apiKeyProvider: AWSAPIKeyAuthProvider) {
        self.apiKeyProvider = apiKeyProvider
        self.endPointToProvider = [:]
    }

    func connection(for url: URL, connectionType: SubscriptionConnectionType, overrideConnectionTimeoutInSeconds: Int?) -> SubscriptionConnection {

        let connectionProvider = endPointToProvider[url.absoluteString] ??
            ConnectionProviderFactory.createConnectionProvider(for: url,
                                                                  authInterceptor: APIKeyAuthInterceptor(apiKeyProvider.getAPIKey()),
                                                                  connectionType: connectionType,
                                                                  overrideConnectionTimeoutInSeconds: overrideConnectionTimeoutInSeconds)
        endPointToProvider[url.absoluteString] = connectionProvider
        let connection = AppSyncSubscriptionConnection(provider: connectionProvider)
        return connection
    }
}
