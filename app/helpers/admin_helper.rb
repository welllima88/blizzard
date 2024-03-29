module AdminHelper
  
  def hourTo24(hour, ampm)
    if ampm == 'am'
      if hour == '12'
        return 0
      else
        return hour
      end
    else
      if hour != '12'
        return (hour.to_i+12)
      else
        return 12
      end
    end
  end
  
  def select_state(model, field, default)
    select_tag("#{model}[#{field}]",  options_for_select([
    							['Alaska', 'AK'],
    							['Alabama', 'AL'],
    							['Arkansas', 'AR'],
    							['Arizona', 'AZ'],
    							['California', 'CA'],
    							['Colorado', 'CO'],
    							['Connecticut', 'CT'],
    							['District of Columbia', 'DC'],
    							['Delaware', 'DE'],
    							['Florida', 'FL'],
    							['Georgia', 'GA'],
    							['Hawaii', 'HI'],
    							['Iowa', 'IA'],
    							['Idaho', 'ID'],
    							['Illinois', 'IL'],
    							['Indiana', 'IN'],
    							['Kansas', 'KS'],
    							['Kentucky', 'KY'],
    							['Louisiana', 'LA'],
    							['Massachusetts', 'MA'],
    							['Maryland', 'MD'],
    							['Maine', 'ME'],
    							['Michigan', 'MI'],
    							['Minnesota', 'MN'],
    							['Missouri', 'MO'],
    							['Mississippi', 'MS'],
    							['Montana', 'MT'],
    							['North Carolina', 'NC'],
    							['North Dakota', 'ND'],
    							['Nebraska', 'NE'],
    							['New Hampshire', 'NH'],
    							['New Jersey', 'NJ'],
    							['New Mexico', 'NM'],
    							['Nevada', 'NV'],
    							['New York', 'NY'],
    							['Ohio', 'OH'],
    							['Oklahoma', 'OK'],
    							['Oregon', 'OR'],
    							['Pennsylvania', 'PA'],
    							['Puerto Rico', 'PR'],
    							['Rhode Island', 'RI'],
    							['South Carolina', 'SC'],
    							['South Dakota', 'SD'],
    							['Tennessee', 'TN'],
    							['Texas', 'TX'],
    							['Utah', 'UT'],
    							['Virginia', 'VA'],
    							['Vermont', 'VT'],
    							['Washington', 'WA'],
    							['Wisconsin', 'WI'],
    							['West Virginia', 'WV'],
    							['Wyoming', 'WY']], "#{default}"), :class => 'form-control')
  end
  
  def select_country(model, field, default)
		select_tag "#{model}[#{field}]", 
		options_for_select(
		{
			'United States' => 'US',
			'Canada' => 'CA',
			'-------------' => '',
			'Albania'=>'AL',
			'Algeria'=>'DZ',
			'AmericanSamoa'=>'AS',
			'Andorra'=>'AD',
			'Angola'=>'AO',
			'Anguilla'=>'AI',
			'Antarctica'=>'AQ',
			'Antigua and Barbuda'=>'AG',
			'Argentina'=>'AR',
			'Armenia'=>'AM',
			'Aruba'=>'AW',
			'Australia'=>'AU',
			'Austria'=>'AT',
			'Azerbaidjan'=>'AZ',
			'Bahamas'=>'BS',
			'Bahrain'=>'BH',
			'Bangladesh'=>'BD',
			'Barbados'=>'BB',
			'Belarus'=>'BY',
			'Belgium'=>'BE',
			'Belize'=>'BZ',
			'Benin'=>'BJ',
			'Bermuda'=>'BM',
			'Bhutan'=>'BT',
			'Bolivia'=>'BO',
			'Bosnia-Herzegovina'=>'BA',
			'Botswana'=>'BW',
			'Bouvet Island'=>'BV',
			'Brazil'=>'BR',
			'BritishIndianOceanTerritory'=>'IO',
			'Brunei Darussalam'=>'BN',
			'Bulgaria'=>'BG',
			'BurkinaFaso'=>'BF',
			'Burundi'=>'BI',
			'Cambodia'=>'KH',
			'Cameroon'=>'CM',
			'CapeVerde'=>'CV',
			'Cayman Islands'=>'KY',
			'CentralAfricanRepublic'=>'CF',
			'Chad'=>'TD',
			'Chile'=>'CL',
			'China'=>'CN',
			'Christmas Island'=>'CX',
			'Cocos(Keeling) Islands'=>'CC',
			'Colombia'=>'CO',
			'Comoros'=>'KM',
			'Congo'=>'CG',
			'Cook Islands'=>'CK',
			'CostaRica'=>'CR',
			'Croatia'=>'HR',
			'Cuba'=>'CU',
			'Cyprus'=>'CY',
			'CzechRepublic'=>'CZ',
			'Denmark'=>'DK',
			'Djibouti'=>'DJ',
			'Dominica'=>'DM',
			'DominicanRepublic'=>'DO',
			'EastTimor'=>'TP',
			'Ecuador'=>'EC',
			'Egypt'=>'EG',
			'ElSalvador'=>'SV',
			'EquatorialGuinea'=>'GQ',
			'Eritrea'=>'ER',
			'Estonia'=>'EE',
			'Ethiopia'=>'ET',
			'Falkland Islands'=>'FK',
			'Faroe Islands'=>'FO',
			'Fiji'=>'FJ',
			'Finland'=>'FI',
			'FormerCzechoslovakia'=>'CS',
			'FormerUSSR'=>'SU',
			'France'=>'FR',
			'France(EuropeanTerritory)'=>'FX',
			'FrenchGuyana'=>'GF',
			'FrenchSouthernTerritories'=>'TF',
			'Gabon'=>'GA',
			'Gambia'=>'GM',
			'Georgia'=>'GE',
			'Germany'=>'DE',
			'Ghana'=>'GH',
			'Gibraltar'=>'GI',
			'GreatBritain'=>'GB',
			'Greece'=>'GR',
			'Greenland'=>'GL',
			'Grenada'=>'GD',
			'Guadeloupe(French)'=>'GP',
			'Guam(USA)'=>'GU',
			'Guatemala'=>'GT',
			'Guinea'=>'GN',
			'GuineaBissau'=>'GW',
			'Guyana'=>'GY',
			'Haiti'=>'HT',
			'Heard and McDonald Islands'=>'HM',
			'Honduras'=>'HN',
			'HongKong'=>'HK',
			'Hungary'=>'HU',
			'Iceland'=>'IS',
			'India'=>'IN',
			'Indonesia'=>'ID',
			'I International'=>'INT',
			'Iran'=>'IR',
			'Iraq'=>'IQ',
			'Ireland'=>'IE',
			'Israel'=>'IL',
			'Italy'=>'IT',
			'Ivory Coast(Ivoire)'=>'CI',
			'Jamaica'=>'JM',
			'Japan'=>'JP',
			'Jordan'=>'JO',
			'Kazakhstan'=>'KZ',
			'Kenya'=>'KE',
			'Kiribati'=>'KI',
			'Kuwait'=>'KW',
			'Kyrgyzstan'=>'KG',
			'Laos'=>'LA',
			'Latvia'=>'LV',
			'Lebanon'=>'LB',
			'Lesotho'=>'LS',
			'Liberia'=>'LR',
			'Libya'=>'LY',
			'Liechtenstein'=>'LI',
			'Lithuania'=>'LT',
			'Luxembourg'=>'LU',
			'Macau'=>'MO',
			'Macedonia'=>'MK',
			'Madagascar'=>'MG',
			'Malawi'=>'MW',
			'Malaysia'=>'MY',
			'Maldives'=>'MV',
			'Mali'=>'ML',
			'Malta'=>'MT',
			'Marshall Islands'=>'MH',
			'Martinique(French)'=>'MQ',
			'Mauritania'=>'MR',
			'Mauritius'=>'MU',
			'Mayotte'=>'YT',
			'Mexico'=>'MX',
			'Micronesia'=>'FM',
			'Moldavia'=>'MD',
			'Monaco'=>'MC',
			'Mongolia'=>'MN',
			'Montserrat'=>'MS',
			'Morocco'=>'MA',
			'Mozambique'=>'MZ',
			'Myanmar'=>'MM',
			'Namibia'=>'NA',
			'Nauru'=>'NR',
			'Nepal'=>'NP',
			'Netherlands'=>'NL',
			'NetherlandsAntilles'=>'AN',
			'NeutralZone'=>'NT',
			'NewCaledonia(French)'=>'NC',
			'NewZealand'=>'NZ',
			'Nicaragua'=>'NI',
			'Niger'=>'NE',
			'Nigeria'=>'NG',
			'Niue'=>'NU',
			'Norfolk Island'=>'NF',
			'NorthKorea'=>'KP',
			'NorthernMariana Islands'=>'MP',
			'Norway'=>'NO',
			'Oman'=>'OM',
			'Pakistan'=>'PK',
			'Palau'=>'PW',
			'Panama'=>'PA',
			'PapuaNewGuinea'=>'PG',
			'Paraguay'=>'PY',
			'Peru'=>'PE',
			'Philippines'=>'PH',
			'Pitcairn Island'=>'PN',
			'Poland'=>'PL',
			'Polynesia(French)'=>'PF',
			'Portugal'=>'PT',
			'PuertoRico'=>'PR',
			'Qatar'=>'QA',
			'Reunion(French)'=>'RE',
			'Romania'=>'RO',
			'RussianFederation'=>'RU',
			'Rwanda'=>'RW',
			'S.Georgia&S.SandwichIsls.'=>'GS',
			'SaintHelena'=>'SH',
			'SaintKitts & Nevis Anguilla'=>'KN',
			'SaintLucia'=>'LC',
			'SaintPierre and Miquelon'=>'PM',
			'SaintTome(SaoTome)andPrincipe'=>'ST',
			'SaintVincent&Grenadines'=>'VC',
			'Samoa'=>'WS',
			'SanMarino'=>'SM',
			'SaudiArabia'=>'SA',
			'Senegal'=>'SN',
			'Seychelles'=>'SC',
			'SierraLeone'=>'SL',
			'Singapore'=>'SG',
			'SlovakRepublic'=>'SK',
			'Slovenia'=>'SI',
			'Solomon Islands'=>'SB',
			'Somalia'=>'SO',
			'SouthAfrica'=>'ZA',
			'SouthKorea'=>'KR',
			'Spain'=>'ES',
			'SriLanka'=>'LK',
			'Sudan'=>'SD',
			'Suriname'=>'SR',
			'SvalbardandJanMayen Islands'=>'SJ',
			'Swaziland'=>'SZ',
			'Sweden'=>'SE',
			'Switzerland'=>'CH',
			'Syria'=>'SY',
			'Tadjikistan'=>'TJ',
			'Taiwan'=>'TW',
			'Tanzania'=>'TZ',
			'Thailand'=>'TH',
			'Togo'=>'TG',
			'Tokelau'=>'TK',
			'Tonga'=>'TO',
			'TrinidadandTobago'=>'TT',
			'Tunisia'=>'TN',
			'Turkey'=>'TR',
			'Turkmenistan'=>'TM',
			'TurksandCaicos Islands'=>'TC',
			'Tuvalu'=>'TV',
			'Uganda'=>'UG',
			'Ukraine'=>'UA',
			'UnitedArabEmirates'=>'AE',
			'UnitedKingdom'=>'GB',
			'Uruguay'=>'UY',
			'USAMilitary'=>'MIL',
			'USAMinorOutlying Islands'=>'UM',
			'Uzbekistan'=>'UZ',
			'Vanuatu'=>'VU',
			'VaticanCityState'=>'VA',
			'Venezuela'=>'VE',
			'Vietnam'=>'VN',
			'Virgin Islands(British)'=>'VG',
			'Virgin Islands(USA)'=>'VI',
			'WallisandFutuna Islands'=>'WF',
			'WesternSahara'=>'EH',
			'Yemen'=>'YE',
			'Yugoslavia'=>'YU',
			'Zaire'=>'ZR',
			'Zambia'=>'ZM',
			'Zimbabwe'=>'ZW',
			
			}, "#{default}"), :class => 'form-control'
  end
  
  def to_money(value)
    return number_with_precision(value, :precision => 2)
  end
  
end
