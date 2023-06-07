#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Locale.Country.Enum do
  use Noizu.DomainObject
  @vsn 1.0
  @nmid_index 248
  @sref "locale_country"
  @enum_list [
    {:__, 0},
    {:AF, 1},
    #AFGHANISTAN
    {:AL, 2},
    #ALBANIA
    {:DZ, 3},
    #ALGERIA
    {:AS, 4},
    #AMERICAN SAMOA
    {:AD, 5},
    #ANDORRA
    {:AO, 6},
    #ANGOLA
    {:AQ, 7},
    #ANTARCTICA
    {:AG, 8},
    #ANTIGUA AND BARBUDA
    {:AR, 9},
    #ARGENTINA
    {:AM, 10},
    #ARMENIA
    {:AW, 11},
    #ARUBA
    {:AU, 12},
    #AUSTRALIA
    {:AT, 13},
    #AUSTRIA
    {:AZ, 14},
    #AZERBAIJAN
    {:BS, 15},
    #BAHAMAS
    {:BH, 16},
    #BAHRAIN
    {:BD, 17},
    #BANGLADESH
    {:BB, 18},
    #BARBADOS
    {:BY, 19},
    #BELARUS
    {:BE, 20},
    #BELGIUM
    {:BZ, 21},
    #BELIZE
    {:BJ, 22},
    #BENIN
    {:BM, 23},
    #BERMUDA
    {:BT, 24},
    #BHUTAN
    {:BO, 25},
    #BOLIVIA
    {:BA, 26},
    #BOSNIA AND HERZEGOVINA
    {:BW, 27},
    #BOTSWANA
    {:BV, 28},
    #BOUVET ISLAND
    {:BR, 29},
    #BRAZIL
    {:IO, 30},
    #BRITISH INDIAN OCEAN TERRITORY
    {:BN, 31},
    #BRUNEI DARUSSALAM
    {:BG, 32},
    #BULGARIA
    {:BF, 33},
    #BURKINA FASO
    {:BI, 34},
    #BURUNDI
    {:KH, 35},
    #CAMBODIA
    {:CM, 36},
    #CAMEROON
    {:CA, 37},
    #CANADA
    {:CV, 38},
    #CAPE VERDE
    {:KY, 39},
    #CAYMAN ISLANDS
    {:CF, 40},
    #CENTRAL AFRICAN REPUBLIC
    {:TD, 41},
    #CHAD
    {:CL, 42},
    #CHILE
    {:CN, 43},
    #CHINA
    {:CX, 44},
    #CHRISTMAS ISLAND
    {:CC, 45},
    #COCOS (KEELING) ISLANDS
    {:CO, 46},
    #COLOMBIA
    {:KM, 47},
    #COMOROS
    {:CG, 48},
    #CONGO
    {:CD, 49},
    #CONGO, THE DEMOCRATIC REPUBLIC OF THE
    {:CK, 50},
    #COOK ISLANDS
    {:CR, 51},
    #COSTA RICA
    {:CI, 52},
    #CÔTE D'IVOIRE
    {:HR, 53},
    #CROATIA
    {:CU, 54},
    #CUBA
    {:CY, 55},
    #CYPRUS
    {:CZ, 56},
    #CZECH REPUBLIC
    {:DK, 57},
    #DENMARK
    {:DJ, 58},
    #DJIBOUTI
    {:DM, 59},
    #DOMINICA
    {:DO, 60},
    #DOMINICAN REPUBLIC
    {:EC, 61},
    #ECUADOR
    {:EG, 62},
    #EGYPT
    {:SV, 63},
    #EL SALVADOR
    {:GQ, 64},
    #EQUATORIAL GUINEA
    {:ER, 65},
    #ERITREA
    {:EE, 66},
    #ESTONIA
    {:ET, 67},
    #ETHIOPIA
    {:FK, 68},
    #FALKLAND ISLANDS (MALVINAS)
    {:FO, 69},
    #FAROE ISLANDS
    {:FJ, 70},
    #FIJI
    {:FI, 71},
    #FINLAND
    {:FR, 72},
    #FRANCE
    {:GF, 73},
    #FRENCH GUIANA
    {:PF, 74},
    #FRENCH POLYNESIA
    {:TF, 75},
    #FRENCH SOUTHERN TERRITORIES
    {:GA, 76},
    #GABON
    {:GM, 77},
    #GAMBIA
    {:GE, 78},
    #GEORGIA
    {:DE, 79},
    #GERMANY
    {:GH, 80},
    #GHANA
    {:GI, 81},
    #GIBRALTAR
    {:GR, 82},
    #GREECE
    {:GL, 83},
    #GREENLAND
    {:GD, 84},
    #GRENADA
    {:GP, 85},
    #GUADELOUPE
    {:GU, 86},
    #GUAM
    {:GT, 87},
    #GUATEMALA
    {:GN, 88},
    #GUINEA
    {:GW, 89},
    #GUINEA-BISSAU
    {:GY, 90},
    #GUYANA
    {:HT, 91},
    #HAITI
    {:HM, 92},
    #HEARD ISLAND AND MCDONALD ISLANDS
    {:HN, 93},
    #HONDURAS
    {:HK, 94},
    #HONG KONG
    {:HU, 95},
    #HUNGARY
    {:IS, 96},
    #ICELAND
    {:IN, 97},
    #INDIA
    {:ID, 98},
    #INDONESIA
    {:IR, 99},
    #IRAN, ISLAMIC REPUBLIC OF
    {:IQ, 100},
    #IRAQ
    {:IE, 101},
    #IRELAND
    {:IL, 102},
    #ISRAEL
    {:IT, 103},
    #ITALY
    {:JM, 104},
    #JAMAICA
    {:JP, 105},
    #JAPAN
    {:JO, 106},
    #JORDAN
    {:KZ, 107},
    #KAZAKHSTAN
    {:KE, 108},
    #KENYA
    {:KI, 109},
    #KIRIBATI
    {:KP, 110},
    #KOREA, DEMOCRATIC PEOPLE'S REPUBLIC OF
    {:KR, 111},
    #KOREA, REPUBLIC OF
    {:KW, 112},
    #KUWAIT
    {:KG, 113},
    #KYRGYZSTAN
    {:LA, 114},
    #LAO PEOPLE'S DEMOCRATIC REPUBLIC
    {:LV, 115},
    #LATVIA
    {:LB, 116},
    #LEBANON
    {:LS, 117},
    #LESOTHO
    {:LR, 118},
    #LIBERIA
    {:LY, 119},
    #LIBYAN ARAB JAMAHIRIYA
    {:LI, 120},
    #LIECHTENSTEIN
    {:LT, 121},
    #LITHUANIA
    {:LU, 122},
    #LUXEMBOURG
    {:MO, 123},
    #MACAO
    {:MK, 124},
    #MACEDONIA, THE FORMER YUGOSLAV REPUBLIC OF
    {:MG, 125},
    #MADAGASCAR
    {:MW, 126},
    #MALAWI
    {:MY, 127},
    #MALAYSIA
    {:MV, 128},
    #MALDIVES
    {:ML, 129},
    #MALI
    {:MT, 130},
    #MALTA
    {:MH, 131},
    #MARSHALL ISLANDS
    {:MQ, 132},
    #MARTINIQUE
    {:MR, 133},
    #MAURITANIA
    {:MU, 134},
    #MAURITIUS
    {:YT, 135},
    #MAYOTTE
    {:MX, 136},
    #MEXICO
    {:FM, 137},
    #MICRONESIA, FEDERATED STATES OF
    {:MD, 138},
    #MOLDOVA, REPUBLIC OF
    {:MD, 139},
    #MONACO
    {:MN, 140},
    #MONGOLIA
    {:MS, 141},
    #MONTSERRAT
    {:MA, 142},
    #MOROCCO
    {:MZ, 143},
    #MOZAMBIQUE
    {:MM, 144},
    #MYANMAR
    {:NA, 145},
    #NAMIBIA
    {:NR, 146},
    #NAURU
    {:NP, 147},
    #NEPAL
    {:NL, 148},
    #NETHERLANDS
    {:AN, 149},
    #NETHERLANDS ANTILLES
    {:NC, 150},
    #NEW CALEDONIA
    {:NZ, 151},
    #NEW ZEALAND
    {:NI, 152},
    #NICARAGUA
    {:NE, 153},
    #NIGER
    {:NG, 154},
    #NIGERIA
    {:NU, 155},
    #NIUE
    {:NF, 156},
    #NORFOLK ISLAND
    {:MP, 157},
    #NORTHERN MARIANA ISLANDS
    {:NO, 158},
    #NORWAY
    {:OM, 159},
    #OMAN
    {:PK, 160},
    #PAKISTAN
    {:PW, 161},
    #PALAU
    {:PS, 162},
    #PALESTINIAN TERRITORY, OCCUPIED
    {:PA, 163},
    #PANAMA
    {:PG, 164},
    #PAPUA NEW GUINEA
    {:PY, 165},
    #PARAGUAY
    {:PE, 166},
    #PERU
    {:PH, 167},
    #PHILIPPINES
    {:PN, 168},
    #PITCAIRN
    {:PL, 169},
    #POLAND
    {:PR, 170},
    #PUERTO RICO
    {:QA, 171},
    #QATAR
    {:RE, 172},
    #RÉUNION
    {:RO, 173},
    #ROMANIA
    {:RU, 174},
    #RUSSIAN FEDERATION
    {:RW, 175},
    #RWANDA
    {:SH, 176},
    #SAINT HELENA
    {:KN, 177},
    #SAINT KITTS AND NEVIS
    {:LC, 178},
    #SAINT LUCIA
    {:PM, 179},
    #SAINT PIERRE AND MIQUELON
    {:VC, 180},
    #SAINT VINCENT AND THE GRENADINES
    {:WS, 181},
    #SAMOA
    {:SM, 182},
    #SAN MARINO
    {:ST, 183},
    #SAO TOME AND PRINCIPE
    {:SA, 184},
    #SAUDI ARABIA
    {:SN, 185},
    #SENEGAL
    {:CS, 186},
    #SERBIA AND MONTENEGRO
    {:SC, 187},
    #SEYCHELLES
    {:SL, 188},
    #SIERRA LEONE
    {:SG, 189},
    #SINGAPORE
    {:SK, 190},
    #SLOVAKIA
    {:SI, 191},
    #SLOVENIA
    {:SB, 192},
    #SOLOMON ISLANDS
    {:SO, 193},
    #SOMALIA
    {:ZA, 194},
    #SOUTH AFRICA
    {:GS, 195},
    #SOUTH GEORGIA AND THE SOUTH SANDWICH ISLANDS
    {:ES, 196},
    #SPAIN
    {:LK, 197},
    #SRI LANKA
    {:SD, 198},
    #SUDAN
    {:SR, 199},
    #SURINAME
    {:SJ, 200},
    #SVALBARD AND JAN MAYEN
    {:SZ, 201},
    #SWAZILAND
    {:SE, 202},
    #SWEDEN
    {:CH, 203},
    #SWITZERLAND
    {:SY, 204},
    #SYRIAN ARAB REPUBLIC
    {:TW, 205},
    #TAIWAN, PROVINCE OF CHINA
    {:TJ, 206},
    #TAJIKISTAN
    {:TZ, 207},
    #TANZANIA, UNITED REPUBLIC OF
    {:TH, 208},
    #THAILAND
    {:TL, 209},
    #TIMOR-LESTE
    {:TG, 210},
    #TOGO
    {:TK, 211},
    #TOKELAU
    {:TO, 212},
    #TONGA
    {:TT, 213},
    #TRINIDAD AND TOBAGO
    {:TN, 214},
    #TUNISIA
    {:TR, 215},
    #TURKEY
    {:TM, 216},
    #TURKMENISTAN
    {:TC, 217},
    #TURKS AND CAICOS ISLANDS
    {:TV, 218},
    #TUVALU
    {:UG, 219},
    #UGANDA
    {:UA, 220},
    #UKRAINE
    {:AE, 221},
    #UNITED ARAB EMIRATES
    {:GB, 222},
    #UNITED KINGDOM
    {:US, 223},
    #UNITED STATES
    {:UM, 224},
    #UNITED STATES MINOR OUTLYING ISLANDS
    {:UY, 225},
    #URUGUAY
    {:UZ, 226},
    #UZBEKISTAN
    {:VU, 227},
    #VANUATU
    {:VE, 228},
    #VENEZUELA
    {:VN, 229},
    #VIET NAM
    {:VG, 230},
    #VIRGIN ISLANDS, BRITISH
    {:VI, 231},
    #VIRGIN ISLANDS, U.S.
    {:WF, 232},
    #WALLIS AND FUTUNA
    {:EH, 233},
    #WESTERN SAHARA
    {:YE, 234},
    #YEMEN
    {:ZM, 235},
    #ZAMBIA
    {:ZW, 236},
    #ZIMBABWE
  ]
  @default_value :__
  @ecto_type :integer
  @persistence_layer :mnesia
  @persistence_layer {:ecto, cascade?: true}
  @json_format_group {:user_clients, [:compact]}
  @json_provider Jetzy.Poison.LookupValueEncoder
  defmodule Entity do
    @auto_generate false
    @universal_identifier false
    @nmid_bare true
    Noizu.DomainObject.noizu_entity do
      @meta {:enum_entity, true}
      identifier :integer

      @json {:*, :expand}
      @json_embed {:user_clients, [{:title, as: :name}]}
      @json_embed {:verbose_mobile, [{:title, as: :name}, {:body, as: :description}, {:editor, sref: true}, :revision]}
      public_field :description, nil, type: Jetzy.VersionedString.TypeHandler

      public_field :iso_3166_code

      @json_ignore :user_clients
      @json_embed {:verbose_mobile, [:created_on]}
      public_field :time_stamp, nil, Noizu.DomainObject.TimeStamp.Second.TypeHandler
    end
  end
  defmodule Repo do
    Noizu.DomainObject.noizu_repo do

    end
  end

end
