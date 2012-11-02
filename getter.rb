# encoding: UTF-8
require 'curb'

http = Curl::Easy.perform("https://internetbank.swedbank.se/idp/portal") do |curl|
    curl.headers["Host"] = "internetbank.swedbank.se"
    curl.headers["Origin"] = "https://internetbank.swedbank.se"
    curl.headers["Referer"] = "https://internetbank.swedbank.se/bviPrivat/privat?ns=1"
    curl.headers["Cookie"] = "SWBTC=R2H/0KI/4QxzSU/4Oi/+nmxtVoI=:MjMwNDViMWE6MTM3YzI1NTBiZDM6YzNl:yclHXQ==; ekensession=rd1o00000000000000000000ffff0a9b3022o443; _Gui_State_=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; SWBTC=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; ekensession=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; passivelogout=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; _portal_SessionID_=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; _portal_State_=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; _portal_shadow_cookie_=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; _dapportal_shadow_cookie_=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; WT_FPC=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; WT_FPC=id=46.59.16.86-3780651008.30229527:lv=1348507696563:ss=1348504110132; JSESSIONID=0000fkVtYYSEVKuMY_iAQLmuN54:176oi17b4; BROWSERCONTROL=control"
    curl.http_post(Curl::PostField.content('authid', "2CE08754-82E7-1797-09CF-958A616678BF"))
end
puts http.body_str

c = Curl::Easy.http_post("https://internetbank.swedbank.se/idp/portal/identifieringidp/idp/dap1/ver=2.0/action/rparam=execution=e1s2",
                         Curl::PostField.content('execution', 'e1s1'),
                         Curl::PostField.content('auth:kundnummer', '8909097878'),
                         Curl::PostField.content('auth:method_2', "PIN6"),
                         Curl::PostField.content('auth:efield', "1"),
                         Curl::PostField.content('auth:fortsett_knapp', "Fortsätt"),
                         Curl::PostField.content('auth_SUBMIT', "1"),
                         Curl::PostField.content('javax.faces.ViewState', "rO0ABXVyABNbTGphdmEubGFuZy5PYmplY3Q7kM5YnxBzKWwCAAB4cAAAAAN0AAExcHQAHy9XRUItSU5GL2Zsb3dzL2lkcC91c2VyaWQueGh0bWw="))
#puts c.body_str
