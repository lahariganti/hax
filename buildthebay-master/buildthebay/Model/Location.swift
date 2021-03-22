//
//  State.swift
//  buildthebay
//
//  Created by Frederico Murakawa on 4/5/19.
//  Copyright © 2019 Lahari Ganti. All rights reserved.
//

struct Location {
    var zipCode: String?
    var city: String?
    var state: State?
}

enum State: String {
    case alaska = "Alaska"
    case alabama = "Alabama"
    case arkansas = "Arkansas"
    case americansamoa = "American Samoa"
    case arizona = "Arizona"
    case california = "California"
    case colorado = "Colorado"
    case connecticut = "Connecticut"
    case districtofcolumbia = "District of Columbia"
    case delaware = "Delaware"
    case florida = "Florida"
    case georgia = "Georgia"
    case guam = "Guam"
    case hawaii = "Hawaii"
    case iowa = "Iowa"
    case idaho = "Idaho"
    case illinois = "Illinois"
    case indiana = "Indiana"
    case kansas = "Kansas"
    case kentucky = "Kentucky"
    case louisiana = "Louisiana"
    case massachusetts = "Massachusetts"
    case maryland = "Maryland"
    case maine = "Maine"
    case michigan = "Michigan"
    case minnesota = "Minnesota"
    case missouri = "Missouri"
    case mississippi = "Mississippi"
    case montana = "Montana"
    case northcarolina = "North Carolina"
    case northdakota = "North Dakota"
    case nebraska = "Nebraska"
    case newhampshire = "New Hampshire"
    case newjersey = "New Jersey"
    case newmexico = "New Mexico"
    case nevada = "Nevada"
    case newyork = "New York"
    case ohio = "Ohio"
    case oklahoma = "Oklahoma"
    case oregon = "Oregon"
    case pennsylvania = "Pennsylvania"
    case puertorico = "Puerto Rico"
    case rhodeisland = "Rhode Island"
    case southcarolina = "South Carolina"
    case southdakota = "South Dakota"
    case tennessee = "Tennessee"
    case texas = "Texas"
    case utah = "Utah"
    case virginia = "Virginia"
    case virginislands = "Virgin Islands"
    case vermont = "Vermont"
    case washington = "Washington"
    case wisconsin = "Wisconsin"
    case westvirginia = "West Virginia"
    case wyoming = "Wyoming"
}
