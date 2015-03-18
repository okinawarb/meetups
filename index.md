---
layout: default
title: Okinawa.rb meetups
---
### <a name="welcome-to-github-pages" class="anchor" href="#welcome-to-github-pages"><span class="octicon octicon-link"></span></a>Welcome to Okinawa.rb
こんにちはこんにちは!

#### Okinawa.rb meetup!とは
沖縄のRuby/Railsコミュニュティです。
沖縄のRuby/Railsな方々の情報交換を主な目的として活動しています。

もしも質問等があれば、Twitterで [#okinawarb](https://twitter.com/search?f=realtime&q=%23okinawarb&src=typd) のハッシュタグを付けてつぶやくか、GitHubのissueに書いてください。
よろしくおねがいします。

##### 場所・時間
時間: 毎月水曜日19時〜 <br/>
場所: MGWave ([那覇市金城3-8-9 一粒ビル401](https://www.google.co.jp/maps/place/%E3%80%92901-0155+%E6%B2%96%E7%B8%84%E7%9C%8C%E9%82%A3%E8%A6%87%E5%B8%82%E9%87%91%E5%9F%8E%EF%BC%93%E4%B8%81%E7%9B%AE%EF%BC%98%E2%88%92%EF%BC%99+%E4%B8%80%E7%B2%92%E4%B8%8D%E5%8B%95%E7%94%A3%E3%83%93%E3%83%AB/@26.2008815,127.6614647,18z/data=!4m7!1m4!3m3!1s0x34e569b7a6a4956f:0xd16d7ba7cca40ef2!2z44CSOTAxLTAxNTUg5rKW57iE55yM6YKj6KaH5biC6YeR5Z-O77yT5LiB55uu77yY4oiS77yZIOS4gOeykuS4jeWLleeUo-ODk-ODqw!3b1!3m1!1s0x34e569b7a6a4956f:0xd16d7ba7cca40ef2))

##### 直近のMonthly meetup

- [第160回 Okinawa.rb Meetup! - Okinawa.rb | Doorkeeper](https://okinawarb.doorkeeper.jp/events/21390)

##### 参加者にお願いしたいこと(MAY)
Okinawa.rbは100回を超えるMeetupを開催していますがあまり活動記録がたまってないので、活動記録を残したいと考えています。

可能であれば、[okinawarb/meetupsにissueをたてて](https://github.com/okinawarb/meetups/issues?state=open)、やったことの記事を書いて、そのissueを閉じるPull Requestを送ってください。(書かなくてもOKです)

[great-h.github.io](http://great-h.github.io/)や[yochiyochirb/meetups](https://github.com/yochiyochirb/meetups)を参考にしたいと思ってます。

##### 記事の書き方(ブラウザから書く方法)
1. GitHubにログインした状態で[ブラウザでこのページを開いてください](https://github.com/okinawarb/meetups/new/gh-pages/_posts?filename=2014-05-07-no117-your_name.markdown&value=---%0Alayout%3A+default%0Atitle%3A++%22Okinawa.rb%20meetup!%20%23117%20%E3%82%84%E3%81%A3%E3%81%9F%E3%81%93%E3%81%A8%20@your_name%22%0Adate%3A+++2014-05-07%0Acategories%3A+no117%0A---%0A%E3%81%93%E3%81%93%E3%81%AB%E3%82%84%E3%81%A3%E3%81%9F%E3%81%93%E3%81%A8%E3%82%92%E6%9B%B8%E3%81%84%E3%81%A6%E3%81%8F%E3%81%A0%E3%81%95%E3%81%84)。
2. `meetups / _posts / [2014-05-07-no117-your_name.markdown]`と表示されてる部分の、`your_name`の部分をあなたの名前に置き換えてください
3. `title`と書いてある行の、`@your_name`の部分をあなたの名前に置き換えてください
4. 最後の`---`の行の下にやったことを書いてください。
5. Propose new fileと書いてあるボタンを押す。
6. Send pull requestと書いてあるボタンを押す。
7. [Pull Requests · okinawarb/meetups](https://github.com/okinawarb/meetups/pulls)に表示されていたらOKです

##### 記事の書き方(Rubyist向け)
[hub コマンドで github から fork して pull request をさくっと - #生存戦略 、それは - subtech](https://subtech.g.hatena.ne.jp/secondlife/20120611/1339411825)を参考にしましょう。

```
% gem install hub
% hub clone okinawarb/meetups
% cd meetups
% hub fork
% git checkout -b no117-meetup-what-i-did
% cat > _posts/2014-05-07-no117-your_name.markdown
---
layout: default
title:  "記事のタイトル"
date:   2014-05-07
categories: no117
---
ここに記事の内容を書く

% git add _posts/2014-05-07-no117-your_name.markdown
% git commit -m '第117回 Okinawa.rb meetup、@yourname の参加記録を書きました'
% git remote
origin
your_name
% git push your_name no117-meetup-what-i-did
% hub pull-request
```

##### 記事の確認方法
```
% bundle install
% bundle exec jekyll server -w
```

ブラウザで[http://localhost:4000/meetups/](http://localhost:4000/meetups/)を開いて確認してください。

<!-- fixme -->
<ul>
{% for post in site.posts %}
  <li>{{ post.date | date_to_string }} - <a href="{{ site.baseurl }}{{ post.url }}">{{ post.title }}</a></li>
{% endfor %}
</ul>
