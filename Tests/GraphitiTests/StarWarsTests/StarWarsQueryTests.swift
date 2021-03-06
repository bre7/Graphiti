import XCTest
@testable import Graphiti

class StarWarsQueryTests : XCTestCase {
    func testHeroNameQuery() throws {
        let query = "query HeroNameQuery {" +
                    "    hero {" +
                    "        name" +
                    "    }" +
                    "}"

        let expected: Map = [
            "data": [
                "hero": [
                    "name": "R2-D2",
                ],
            ],
        ]

        let result = try starWarsSchema.execute(request: query)
        XCTAssertEqual(result, expected)
    }

    func testHeroNameAndFriendsQuery() throws {
        let query = "query HeroNameAndFriendsQuery {" +
                    "    hero {" +
                    "        id" +
                    "        name" +
                    "        friends {" +
                    "            name" +
                    "        }" +
                    "    }" +
                    "}"

        let expected: Map = [
            "data": [
                "hero": [
                    "id": "2001",
                    "name": "R2-D2",
                    "friends": [
                        ["name": "Luke Skywalker"],
                        ["name": "Han Solo"],
                        ["name": "Leia Organa"],
                    ],
                ],
            ],
        ]

        let result = try starWarsSchema.execute(request: query)
        XCTAssertEqual(result, expected)
    }

    func testNestedQuery() throws {
        let query = "query NestedQuery {" +
                    "    hero {" +
                    "        name" +
                    "        friends {" +
                    "            name" +
                    "            appearsIn" +
                    "            friends {" +
                    "                name" +
                    "            }" +
                    "        }" +
                    "    }" +
                    "}"

        let expected: Map = [
            "data": [
                "hero": [
                    "name": "R2-D2",
                    "friends": [
                        [
                            "name": "Luke Skywalker",
                            "appearsIn": ["NEWHOPE", "EMPIRE", "JEDI"],
                            "friends": [
                                ["name": "Han Solo"],
                                ["name": "Leia Organa"],
                                ["name": "C-3PO"],
                                ["name": "R2-D2"],
                            ],
                        ],
                        [
                            "name": "Han Solo",
                            "appearsIn": ["NEWHOPE", "EMPIRE", "JEDI"],
                            "friends": [
                                ["name": "Luke Skywalker"],
                                ["name": "Leia Organa"],
                                ["name": "R2-D2"],
                            ],
                        ],
                        [
                            "name": "Leia Organa",
                            "appearsIn": ["NEWHOPE", "EMPIRE", "JEDI"],
                            "friends": [
                                ["name": "Luke Skywalker"],
                                ["name": "Han Solo"],
                                ["name": "C-3PO"],
                                ["name": "R2-D2"],
                            ],
                        ],
                    ],
                ],
            ],
        ]

        let result = try starWarsSchema.execute(request: query)
        XCTAssertEqual(result, expected)
    }

    func testFetchLukeQuery() throws {
        let query = "query FetchLukeQuery {" +
                    "    human(id: \"1000\") {" +
                    "        name" +
                    "    }" +
                    "}"

        let expected: Map = [
            "data": [
                "human": [
                    "name": "Luke Skywalker",
                ],
            ],
        ]

        let result = try starWarsSchema.execute(request: query)
        XCTAssertEqual(result, expected)
    }

    func testFetchSomeIDQuery() throws {
        let query = "query FetchSomeIDQuery($someId: String!) {" +
                    "    human(id: $someId) {" +
                    "        name" +
                    "    }" +
                    "}"

        var params: [String: Map]
        var expected: Map
        var result: Map

        params = [
            "someId": "1000",
        ]

        expected = [
            "data": [
                "human": [
                    "name": "Luke Skywalker",
                ],
            ],
        ]

        result = try starWarsSchema.execute(request: query, variables: params)
        XCTAssertEqual(result, expected)

        params = [
            "someId": "1002",
        ]

        expected = [
            "data": [
                "human": [
                    "name": "Han Solo",
                ],
            ],
        ]

        result = try starWarsSchema.execute(request: query, variables: params)
        XCTAssertEqual(result, expected)


        params = [
            "someId": "not a valid id",
        ]

        expected = [
            "data": [
                "human": nil,
            ],
        ]

        result = try starWarsSchema.execute(request: query, variables: params)
        XCTAssertEqual(result, expected)
    }

    func testFetchLukeAliasedQuery() throws {
        let query = "query FetchLukeAliasedQuery {" +
                    "    luke: human(id: \"1000\") {" +
                    "        name" +
                    "    }" +
                    "}"

        let expected: Map = [
            "data": [
                "luke": [
                    "name": "Luke Skywalker",
                ],
            ],
        ]

        let result = try starWarsSchema.execute(request: query)
        XCTAssertEqual(result, expected)
    }

    func testFetchLukeAndLeiaAliasedQuery() throws {
        let query = "query FetchLukeAndLeiaAliasedQuery {" +
                    "    luke: human(id: \"1000\") {" +
                    "        name" +
                    "    }" +
                    "    leia: human(id: \"1003\") {" +
                    "        name" +
                    "    }" +
                    "}"

        let expected: Map = [
            "data": [
                "luke": [
                    "name": "Luke Skywalker",
                ],
                "leia": [
                    "name": "Leia Organa",
                ],
            ],
        ]

        let result = try starWarsSchema.execute(request: query)
        XCTAssertEqual(result, expected)
    }

    func testDuplicateFieldsQuery() throws {
        let query = "query DuplicateFieldsQuery {" +
                    "    luke: human(id: \"1000\") {" +
                    "        name" +
                    "        homePlanet { name }" +
                    "    }" +
                    "    leia: human(id: \"1003\") {" +
                    "        name" +
                    "        homePlanet  { name }" +
                    "    }" +
                    "}"

        let expected: Map = [
            "data": [
                "luke": [
                    "name": "Luke Skywalker",
                    "homePlanet": ["name":"Tatooine"],
                ],
                "leia": [
                    "name": "Leia Organa",
                    "homePlanet": ["name":"Alderaan"],
                ],
            ],
        ]

        let result = try starWarsSchema.execute(request: query)
        XCTAssertEqual(result, expected)
    }

    func testUseFragmentQuery() throws {
        let query = "query UseFragmentQuery {" +
                    "    luke: human(id: \"1000\") {" +
                    "        ...HumanFragment" +
                    "    }" +
                    "    leia: human(id: \"1003\") {" +
                    "        ...HumanFragment" +
                    "    }" +
                    "}" +
                    "fragment HumanFragment on Human {" +
                    "    name" +
                    "    homePlanet { name }" +
                    "}"

        let expected: Map = [
            "data": [
                "luke": [
                    "name": "Luke Skywalker",
                    "homePlanet": ["name":"Tatooine"],
                ],
                "leia": [
                    "name": "Leia Organa",
                    "homePlanet": ["name":"Alderaan"],
                ],
            ]
        ]

        let result = try starWarsSchema.execute(request: query)
        XCTAssertEqual(result, expected)
    }

    func testCheckTypeOfR2Query() throws {
        let query = "query CheckTypeOfR2Query {" +
                    "    hero {" +
                    "        __typename" +
                    "        name" +
                    "    }" +
                    "}"

        let expected: Map = [
            "data": [
                "hero": [
                    "__typename": "Droid",
                    "name": "R2-D2",
                ],
            ],
        ]

        let result = try starWarsSchema.execute(request: query)
        XCTAssertEqual(result, expected)
    }

    func testCheckTypeOfLukeQuery() throws {
        let query = "query CheckTypeOfLukeQuery {" +
                    "    hero(episode: EMPIRE) {" +
                    "        __typename" +
                    "        name" +
                    "    }" +
                    "}"

        let expected: Map = [
            "data": [
                "hero": [
                    "__typename": "Human",
                    "name": "Luke Skywalker",
                ],
            ],
        ]

        let result = try starWarsSchema.execute(request: query)
        XCTAssertEqual(result, expected)
    }

    func testSecretBackstoryQuery() throws {
        let query = "query SecretBackstoryQuery {\n" +
                    "    hero {\n" +
                    "        name\n" +
                    "        secretBackstory\n" +
                    "    }\n" +
                    "}\n"

        let expected: Map = [
            "data": [
                "hero": [
                    "name": "R2-D2",
                    "secretBackstory": nil,
                ],
            ],
            "errors": [
                [
                    "message": "secretBackstory is secret.",
                    "path": ["hero", "secretBackstory"],
                    "locations": [["line": 4, "column": 9]],
                ],
            ],
        ]

        let result = try starWarsSchema.execute(request: query)
        XCTAssertEqual(result, expected)
    }

    func testSecretBackstoryListQuery() throws {
        let query = "query SecretBackstoryListQuery {\n" +
                    "    hero {\n" +
                    "        name\n" +
                    "        friends {\n" +
                    "            name\n" +
                    "            secretBackstory\n" +
                    "        }\n" +
                    "    }\n" +
                    "}\n"

        let expected: Map = [
            "data": [
                "hero": [
                    "name": "R2-D2",
                    "friends": [
                        [
                            "name": "Luke Skywalker",
                            "secretBackstory": nil,
                        ],
                        [
                            "name": "Han Solo",
                            "secretBackstory": nil,
                        ],
                        [
                            "name": "Leia Organa",
                            "secretBackstory": nil,
                        ],
                    ],
                ],
            ],
            "errors": [
                [
                    "message": "secretBackstory is secret.",
                    "path": ["hero", "friends", 0, "secretBackstory"],
                    "locations": [["line": 6, "column": 13]],
                ],
                [
                    "message": "secretBackstory is secret.",
                    "path": ["hero", "friends", 1, "secretBackstory"],
                     "locations": [["line": 6, "column": 13]],
                ],
                [
                    "message": "secretBackstory is secret.",
                    "path": ["hero", "friends", 2, "secretBackstory"],
                    "locations": [["line": 6, "column": 13]],
                ],
            ],
        ]

        let result = try starWarsSchema.execute(request: query)
        XCTAssertEqual(result, expected)
    }

    func testSecretBackstoryAliasQuery() throws {
        let query = "query SecretBackstoryAliasQuery {\n" +
                    "    mainHero: hero {\n" +
                    "        name\n" +
                    "        story: secretBackstory\n" +
                    "    }\n" +
                    "}\n"

        let expected: Map = [
            "data": [
                "mainHero": [
                    "name": "R2-D2",
                    "story": nil,
                ],
            ],
            "errors": [
                [
                    "message": "secretBackstory is secret.",
                    "path": ["mainHero", "story"],
                    "locations": [["line": 4, "column": 9]],
                ],
            ]
        ]

        let result = try starWarsSchema.execute(request: query)
        XCTAssertEqual(result, expected)
    }

    func testNonNullableFieldsQuery() throws {
        let schema = try Schema<NoRoot, NoContext> { schema in
            struct A : OutputType {}

            try schema.object(type: A.self) { a in
                try a.field(name: "nullableA", type: (TypeReference<A>?).self) { _ in A() }
                try a.field(name: "nonNullA", type: TypeReference<A>.self) { _ in A() }
                try a.field(name: "throws", type: String.self) { _ in
                    struct 🏃 : Error, CustomStringConvertible {
                        let description: String
                    }

                    throw 🏃(description: "catch me if you can.")
                }
            }

            try schema.query { query in
                try query.field(name: "nullableA", type: (A?).self) { _ in A() }
            }
        }


        let query = "query {\n" +
                    "    nullableA {\n" +
                    "        nullableA {\n" +
                    "            nonNullA {\n" +
                    "                nonNullA {\n" +
                    "                    throws\n" +
                    "                }\n" +
                    "            }\n" +
                    "        }\n" +
                    "    }\n" +
                    "}\n"

        let expected: Map = [
            "data": [
                "nullableA": [
                    "nullableA": nil,
                ],
            ],
            "errors": [
                [
                    "message": "catch me if you can.",
                    "path": ["nullableA", "nullableA", "nonNullA", "nonNullA", "throws"],
                    "locations": [["line": 6, "column": 21]],
                ],
            ],
        ]

        let result = try schema.execute(request: query)
        XCTAssertEqual(result, expected)
    }

    func testSearchQuery() throws {
        let query = "query {" +
            "    search(query: \"o\") {" +
            "        ... on Planet {" +
            "            name " +
            "            diameter " +
            "        }" +
            "        ... on Human {" +
            "            name " +
            "        }" +
            "        ... on Droid {" +
            "            name " +
            "            primaryFunction " +
            "        }" +
            "    }" +
            "}"

        let expected: Map = [
            "data": [
                "search": [
                    [ "name": "Tatooine", "diameter": 10465 ],
                    [ "name": "Han Solo" ],
                    [ "name": "Leia Organa" ],
                    [ "name": "C-3PO", "primaryFunction": "Protocol" ],
                ],
            ],
            ]

        let result = try starWarsSchema.execute(request: query)
        XCTAssertEqual(result, expected)
    }
}

extension StarWarsQueryTests {
    static var allTests: [(String, (StarWarsQueryTests) -> () throws -> Void)] {
        return [
            ("testHeroNameQuery", testHeroNameQuery),
            ("testHeroNameAndFriendsQuery", testHeroNameAndFriendsQuery),
            ("testNestedQuery", testNestedQuery),
            ("testFetchLukeQuery", testFetchLukeQuery),
            ("testFetchSomeIDQuery", testFetchSomeIDQuery),
            ("testFetchLukeAliasedQuery", testFetchLukeAliasedQuery),
            ("testFetchLukeAndLeiaAliasedQuery", testFetchLukeAndLeiaAliasedQuery),
            ("testDuplicateFieldsQuery", testDuplicateFieldsQuery),
            ("testUseFragmentQuery", testUseFragmentQuery),
            ("testCheckTypeOfR2Query", testCheckTypeOfR2Query),
            ("testCheckTypeOfLukeQuery", testCheckTypeOfLukeQuery),
            ("testSecretBackstoryQuery", testSecretBackstoryQuery),
            ("testSecretBackstoryListQuery", testSecretBackstoryListQuery),
            ("testNonNullableFieldsQuery", testNonNullableFieldsQuery),
        ]
    }
}
