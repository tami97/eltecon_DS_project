# Liverpool-meccsek gólkülönbségeinek modellezése
## Kőrösi Péter, Vadász Tamara

## Az elemzés célja:

* Labdarúgó-mérkőzések eredményeinek előrejelzése
  + egy csapat kiválasztása (Liverpool)
  + az adott csapat meccseinek elemzése korábbi eredmények alapján
* 2 modell készítése az eddigi szezonok alapján
  + lineáris regresszió és PCA
* a becsült modell alapján predikció az idei szezonra

## Az adatok

### Forrás: [football-data.co.uk](https://www.football-data.co.uk/englandm.php)

Premier League
2000/01 - 2019/20
Liverpool-meccsek

*Az adatokat letöltő fájl: data_download.ipynb (python)*

A változók:

* Szezon (year)
* Meccs (match)
  + a meccs sorszáma az adott szezonon belül
* Hazai páya (home)
  + dummy (1: Liverpool hazai pálya, 0: Liverpool idegenben)
* Ellenfél (OTHER)
* Gólkülönbség (goal_difference)
  + Liverpool góljainak száma - ellenfél góljainak száma
* Félidei gólkülönbség (half_time_goal_difference)
  + Liverpool góljainak száma a félidőben - ellenfél góljainak száma a félidőben
* A meccs végén a Liverpool pontszáma a szezonban (points)
 + győzelem: +3 pont
 + döntetlen: +1 pont
 + vereség: 0 pont

A következő változók mindkét csapatra (Liverpool: L_\*, Ellenfél: O_\*)
  
* Lőtt gólók száma (goals)
* Lőtt gólok száma félidőben (half_time_goals)
* Lövések száma (shots)
* Kaput eltaláló lövések száma (shots_on_target)
* Szögletek (corners)
* Elkövetett szabálytalanságok (fouls_commited)
* Sárga lapok (yellow_cards)
* Piros lapok (red_cards)
