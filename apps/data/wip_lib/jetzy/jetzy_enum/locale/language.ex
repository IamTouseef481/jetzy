#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Locale.Language.Enum do
  use Noizu.DomainObject
  @vsn 1.0
  @nmid_index 249
  @sref "locale_language"
  @enum_list [
    __: 0,
    ab: 1, #Abkhazian
    aa: 2, #Afar
    af: 3, #Afrikaans
    sq: 4, #Albanian
    am: 5, #Amharic
    ar: 6, #Arabic
    hy: 7, #Armenian
    as: 8, #Assamese
    ay: 9, #Aymara
    az: 10, #Azerbaijani
    ba: 11, #Bashkir
    eu: 12, #Basque
    bn: 13, #Bengali (Bangla)
    dz: 14, #Bhutani
    bh: 15, #Bihari
    bi: 16, #Bislama
    br: 17, #Breton
    bg: 18, #Bulgarian
    my: 19, #Burmese
    be: 20, #Byelorussian (Belarusian)
    km: 21, #Cambodian
    ca: 22, #Catalan
    zh: 23, #Chinese (Simplified)
    zh: 24, #Chinese (Traditional)
    co: 25, #Corsican
    hr: 26, #Croatian
    cs: 27, #Czech
    da: 28, #Danish
    nl: 29, #Dutch
    en: 30, #English
    eo: 31, #Esperanto
    et: 32, #Estonian
    fo: 33, #Faeroese
    fa: 34, #Farsi
    fj: 35, #Fiji
    fi: 36, #Finnish
    fr: 37, #French
    fy: 38, #Frisian
    gl: 39, #Galician
    gd: 40, #Gaelic (Scottish)
    gv: 41, #Gaelic (Manx)
    ka: 42, #Georgian
    de: 43, #German
    el: 44, #Greek
    kl: 45, #Greenlandic
    gn: 46, #Guarani
    gu: 47, #Gujarati
    ha: 48, #Hausa
    he: 49, #Hebrew
    hi: 50, #Hindi
    hu: 51, #Hungarian
    is: 52, #Icelandic
    id: 53, #Indonesian
    ia: 54, #Interlingua
    ie: 55, #Interlingue
    iu: 56, #Inuktitut
    ik: 57, #Inupiak
    ga: 58, #Irish
    it: 59, #Italian
    ja: 60, #Japanese
    ja: 61, #Javanese
    kn: 62, #Kannada
    ks: 63, #Kashmiri
    kk: 64, #Kazakh
    rw: 65, #Kinyarwanda (Ruanda)
    ky: 66, #Kirghiz
    rn: 67, #Kirundi (Rundi)
    ko: 68, #Korean
    ku: 69, #Kurdish
    lo: 70, #Laothian
    la: 71, #Latin
    lv: 72, #Latvian (Lettish)
    li: 73, #Limburgish ( Limburger)
    ln: 74, #Lingala
    lt: 75, #Lithuanian
    mk: 76, #Macedonian
    mg: 77, #Malagasy
    ms: 78, #Malay
    ml: 79, #Malayalam
    mt: 80, #Maltese
    mi: 81, #Maori
    mr: 82, #Marathi
    mo: 83, #Moldavian
    mn: 84, #Mongolian
    na: 85, #Nauru
    ne: 86, #Nepali
    no: 87, #Norwegian
    oc: 88, #Occitan
    or: 89, #Oriya
    om: 90, #Oromo (Afan, Galla)
    ps: 91, #Pashto (Pushto)
    pl: 92, #Polish
    pt: 93, #Portuguese
    pa: 94, #Punjabi
    qu: 95, #Quechua
    rm: 96, #Rhaeto-Romance
    ro: 97, #Romanian
    ru: 98, #Russian
    sm: 99, #Samoan
    sg: 100, #Sangro
    sa: 101, #Sanskrit
    sr: 102, #Serbian
    sh: 103, #Serbo-Croatian
    st: 104, #Sesotho
    tn: 105, #Setswana
    sn: 106, #Shona
    sd: 107, #Sindhi
    si: 108, #Sinhalese
    ss: 109, #Siswati
    sk: 110, #Slovak
    sl: 111, #Slovenian
    so: 112, #Somali
    es: 113, #Spanish
    su: 114, #Sundanese
    sw: 115, #Swahili (Kiswahili)
    sv: 116, #Swedish
    tl: 117, #Tagalog
    tg: 118, #Tajik
    ta: 119, #Tamil
    tt: 120, #Tatar
    te: 121, #Telugu
    th: 122, #Thai
    bo: 123, #Tibetan
    ti: 124, #Tigrinya
    to: 125, #Tonga
    ts: 126, #Tsonga
    tr: 127, #Turkish
    tk: 128, #Turkmen
    tw: 129, #Twi
    ug: 130, #Uighur
    uk: 131, #Ukrainian
    ur: 132, #Urdu
    uz: 133, #Uzbek
    vi: 134, #Vietnamese
    vo: 135, #Volapük
    cy: 136, #Welsh
    wo: 137, #Wolof
    xh: 138, #Xhosa
    yi: 139, #Yiddish
    yo: 140, #Yoruba
    zu: 141,
    #Zulu
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

      public_field :iso_639_code

      @json_ignore :user_clients
      public_field :time_stamp, nil, Noizu.DomainObject.TimeStamp.Second.TypeHandler
    end
  end
  defmodule Repo do
    Noizu.DomainObject.noizu_repo do

    end
  end

end
