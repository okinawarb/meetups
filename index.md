---
layout: default
title: Okinawa.rb meetups
---
### <a name="welcome-to-github-pages" class="anchor" href="#welcome-to-github-pages"><span class="octicon octicon-link"></span></a>Welcome to Okinawa.rb
こんにちはこんにちは!

#### Okinawa.rb meetup!とは
沖縄のRuby/Railsコミュニュティです。
沖縄のRuby/Railsな方々の情報交換を主な目的として活動しています。

もしも質問等があれば、Twitterで #okinawarb のハッシュタグを付けてつぶやくか、GitHubのissueに書いてください。
よろしくおねがいします。

##### 場所・時間
時間: 毎週水曜日19時<br/>
場所: <address>ギークハウス沖縄(那覇市古波蔵2-18-14)</address>

##### 参加者にお願いしたいこと(MAY)
Okinawa.rbは100回を超えるMeetupを開催していますがあまり活動記録がたまってないので、活動記録を残したいと考えています。

可能であれば、[okinawarb/meetupsにissueをたてて](https://github.com/okinawarb/meetups/issues?state=open)、やったことの記事を書いて、そのissueを閉じるPull Requestを送ってください。(書かなくてもOKです)

[great-h.github.io](http://great-h.github.io/)や[yochiyochirb/meetups](https://github.com/yochiyochirb/meetups)を参考にしたいと思ってます。


##### 記事の書き方(Rubyist向け)
[hub コマンドで github から fork して pull request をさくっと - #生存戦略 、それは - subtech](https://subtech.g.hatena.ne.jp/secondlife/20120611/1339411825)を参考にしましょう。

```
% gem install hub
% hub clone okinawarb/meetups
% cd meetups
% hub fork
% git checkout -b no116-meetup-what-i-did
% cat > _posts/2014-05-07-your-article-name.markdown
---
layout: default
title:  "記事のタイトル"
date:   2014-05-07
categories:
---
ここに記事の内容を書く

% git commit -m '第116回 Okinawa.rb meetup、@yourname の参加記録を書きました'
% git remote
origin
your_name
% git push your_name no116-meetup-what-i-did
% hub pull-request
```
<!-- fixme -->
<ul>
{% for post in site.posts %}
  <li>{{ post.date | date_to_string }} - <a href="{{ site.baseurl }}{{ post.url }}">{{ post.title }}</a></li>
{% endfor %}
</ul>
