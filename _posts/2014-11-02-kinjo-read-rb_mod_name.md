---
layout: default
title: "Module 名の決定について @libkinjo"
date: 2014-11-02
categories: no121
---
## [@libkinjo](https://twitter.com/libkinjo)

事の発端は `Okinawa.rb 2014-10-29 Wed` で話のあった以下な件からきている。

    a = Module.new
    a.name #=> nil
    A = a
    a.name #=> "A"

`a.name` はどのように動作して "A" を戻すのか。

結論は `Object` のコンストテーブルを参照し "A" を戻している。

以降、ソースコードで確認する。 gdb での動作確認もする。


-   環境
    -   リポジトリ <https://github.com/kinjo/my-ansible-project.git>
    -   ブランチ rbenv+ruby-reading
    -   本件の環境のビルドについては README.md 参照
    -   ビルド後は `/home/vagrant/ruby` にソースコードが配置され、タグジャンプ用に `/home/vagrant/ruby/tags` （vi 用）が生成される
    -   タグジャンプの説明は割愛

-   対象のソースコード
    -   リポジトリ <https://github.com/ruby/ruby.git>
    -   タグ v2\_1\_5

まず `a.name` メソッドの定義を確認。

    [6] pry(main)> show-source a.name

    From: variable.c (C Method):
    Owner: Module
    Visibility: public
    Number of lines: 9

    VALUE
    rb_mod_name(VALUE mod)
    {
        int permanent;
        VALUE path = classname(mod, &permanent);

        if (!NIL_P(path)) return rb_str_dup(path);
        return path;
    }

定義は `variable.c:rb_mod_name(VALUE mod)` にあり。

`classname()` にタグジャンプ。

`variable.c:classname(VALUE klass, int *permanent)` に以下のように定義あり。コメントは動作推測のメモ。

    /**                                                                    // 命名されていれば klass の classpath を戻し、
     * Returns +classpath+ of _klass_, if it is named, or +nil+ for       // 匿名の class/module の場合 nil を戻す。
     * anonymous +class+/+module+.  The last part of named +classpath+ is // 命名された classpath の最後の部分は無名にならないが、
     * never anonymous, but anonymous +class+/+module+ names may be       // 匿名の class/module 名は含まれるかも。
     * contained.  If the path is "permanent", that means it has no       // path が恒久であれば名前は匿名の名前を含まず
     * anonymous names, <code>*permanent</code> is set to 1.              // *parament は 1 にセットされる。
     */                                                                   //
    static VALUE
    classname(VALUE klass, int *permanent)
    {
        VALUE path = Qnil;
        st_data_t n;

        if (!klass) klass = rb_cObject;                                        // klass なければ Object クラスをセット
        *permanent = 1;                                                       // 恒久パスとす
        if (RCLASS_IV_TBL(klass)) {                                            // klass のインスタンス変数テーブルありな場合
            if (!st_lookup(RCLASS_IV_TBL(klass), (st_data_t)classpath, &n)) {  // インスタンス変数テーブルから classpath なエントリを検索
                                                                               // classpath は __classpath__ なシンボル
                                                                               // n にはハッシュ値がセットされる
                                                                               // エントリありのとき 1 エントリなしのとき 0 戻る
                ID cid = 0;
                if (st_lookup(RCLASS_IV_TBL(klass), (st_data_t)classid, &n)) { // インスタンス変数テーブルに  __classid__ なエントリありなとき（classid は __classid__ なシンボル）
                    cid = SYM2ID(n);                                           // SYM2ID は n をシフト(RUBY_SPECIAL_SHIF==8)
                                                                               // 何かしらシステム的な ID への変換？
                                                                               // @hanachin_ ：シンボルをオブジェクトIDに変換していると予想
                    path = find_class_path(klass, cid);                        // cid で klass からクラスパス検索
                }
                if (NIL_P(path)) {                                             // path が nil なとき
                    path = find_class_path(klass, (ID)0);                      // ID=0 な path 検索（これって nil が戻るでは）
                }
                if (NIL_P(path)) {                                             // path が nil で
                    if (!cid) {                                                // cid もなしなとき
                        return Qnil;                                           // nil オブジェクト戻す
                    }
                    if (!st_lookup(RCLASS_IV_TBL(klass), (st_data_t)tmp_classpath, &n)) { // __tmp_class__ なエントリを確認
                        path = rb_id2str(cid);
                        return path;
                    }
                    *permanent = 0;                       // *parament = 0 、つまり一時パス
                    path = (VALUE)n;                       // 何やら一時的な文字列でもセットするのだろか
                    return path;
                }
            }
            else {                                         // インスタンス変数テーブルに _classpath__ なエントリあるとき
                path = (VALUE)n;
            }
            if (!RB_TYPE_P(path, T_STRING)) {              // 文字列のはずが、そうでないとき
                rb_bug("class path is not set properly");
            }
            return path;
        }
        return find_class_path(klass, (ID)0);              // インスタンス変数テーブルなしのとき実行
    }                                                      // nil が戻る？


以下、 GDB 実行手順。

    RUBYLIB=.ext/x86_64-linux gdb ./ruby
    run -Ilib -I. -e 'Module.new.name'

以下、 `rb_mod_name()` にブレークを仕掛ける手順。


まず `rb_mod_name()` があることを確認。

    (gdb) info functions rb_mod_name
    All functions matching regular expression "rb_mod_name":

    File variable.c:
    VALUE rb_mod_name(VALUE);

ブレークさせる。

    (gdb) break rb_mod_name
    Breakpoint 1 at 0x55555568571c: file variable.c, line 209.
    (gdb) run -Ilib -I. -e 'Module.new.name'
    Starting program: /home/vagrant/ruby/ruby -Ilib -I. -e 'Module.new.name'
    [Thread debugging using libthread_db enabled]
    Using host libthread_db library "/lib/x86_64-linux-gnu/libthread_db.so.1".
    [New Thread 0x7ffff7ff5700 (LWP 31398)]

    Breakpoint 1, rb_mod_name (mod=93825001081160) at variable.c:209
    209         VALUE path = classname(mod, &permanent);

GDB には以下なコマンドあり。詳しくは割愛。


-   `h [c]` - ヘルプ（ `[c]` は `h` のサブコマンド、またはヘルプを参照させたいコマンド）
-   `p [expr]` - `expr` に変数名を指定して値を確認する等
-   `l [n]` - 周辺のソースコードを表示（ `[n]` はソースコードの行番号）
-   `n` - ステップ実行
-   `s` - ステップイン（関数に入る）
-   `bt` - バックトレース

`classname()` の中にステップ・イン。

    Breakpoint 1, rb_mod_name (mod=93825001081160) at variable.c:209
    209         VALUE path = classname(mod, &permanent);
    (gdb) s
    classname (klass=93825001081160, permanent=0x7fffffffd804) at variable.c:159
    159         VALUE path = Qnil;
    (gdb) l
    154      * anonymous names, <code>*permanent</code> is set to 1.
    155      */
    156     static VALUE
    157     classname(VALUE klass, int *permanent)
    158     {
    159         VALUE path = Qnil;
    160         st_data_t n;
    161
    162         if (!klass) klass = rb_cObject;
    163         *permanent = 1;

まず `klass` の内容を確認。

    (gdb) p *klass
    $2 = 35


-   `35` とは
    -   オブジェクトの型を確認

            (gdb) p ((struct RBasic *)klass)->flags&0x1f
            $3 = 3
    -   `0x1f` はオブジェクトの型を調べるマスクな模様
    -   `3` とは
    -   `include/ruby/ruby.h` の `enum ruby_value_type` によると `RUBY_T_MODULE = 0x03`
    -   つまり `Module`

`classname()` の最後までステップ実行。

    (gdb) l 159
    154      * anonymous names, <code>*permanent</code> is set to 1.
    155      */
    156     static VALUE
    157     classname(VALUE klass, int *permanent)
    158     {
    159         VALUE path = Qnil;
    160         st_data_t n;
    161
    162         if (!klass) klass = rb_cObject;
    163         *permanent = 1;
    (gdb) n
    162         if (!klass) klass = rb_cObject;
    (gdb) n
    163         *permanent = 1;
    (gdb) n
    164         if (RCLASS_IV_TBL(klass)) {
    (gdb) n
    195         return find_class_path(klass, (ID)0);
    (gdb) p find_class_path(klass, (ID)0)
    $4 = 8

`find_class_path()` は `8` を戻す。


-   `8` とは
    -   `nil` だと当たりをつけて `NIL_P()` マクロの定義を確認
        -   `NIL_P()` の定義は `!(v != Qnil)`
        -   `Qnil` は `RUBY_Qnil` のことで `include/ruby/ruby.h` によると `RUBY_Qnil   = 0x08`
        -   つまり `8` は `nil` な模様

`find_class_path()` を確認。

    static VALUE
    find_class_path(VALUE klass, ID preferred)
    {
        struct fc_result arg;

        arg.preferred = preferred;
        arg.name = 0;
        arg.path = 0;
        arg.klass = klass;
        arg.track = rb_cObject;
        arg.prev = 0;
        if (RCLASS_CONST_TBL(rb_cObject)) {
            st_foreach_safe(RCLASS_CONST_TBL(rb_cObject), fc_i, (st_data_t)&arg);
        }
        if (arg.path) {
            st_data_t tmp = tmp_classpath;
            if (!RCLASS_IV_TBL(klass)) {
                RCLASS_IV_TBL(klass) = st_init_numtable();
            }
            rb_st_insert_id_and_value(klass, RCLASS_IV_TBL(klass), (st_data_t)classpath, arg.path);
            st_delete(RCLASS_IV_TBL(klass), &tmp, 0);
            return arg.path;
        }
        return Qnil;
    }

`RCLASS_CONST_TBL()` は **Ruby Under a Microscope** によるとコンストテーブル。
そしてどうやら `st_foreach_safe()` はハッシュテーブルのエントリをなめる関数な模様。
テーブルにエントリされている key/value な組みが、ひとつひとつ `fc_i()` に渡る模様。

`fc_i()` の定義は後述。 `fc_i()` はどうやら
コンストテーブルのエントリのうち value が `klass` （＝Module.new）となっているエントリを探す模様。

`Module.new.name` の場合だとコンストテーブルからエントリは発見されず、
`st_foreach_safe()` はパスを発見できず `find_class_path()` は `return Qnil` で抜ける。

以上、 `Module.new.name` は `nil` を戻す件。

次。 `a=Module.new;A=a;puts a.name` の件。

以下で実行。

    RUBYLIB=.ext/x86_64-linux gdb ./ruby
    run -Ilib -I. -e 'a=Module.new;A=a;puts a.name'

前述同様、 `classname()` にステップ・イン。

    Breakpoint 1, rb_mod_name (mod=93825001080720) at variable.c:209
    209         VALUE path = classname(mod, &permanent);
    (gdb) s
    classname (klass=93825001080720, permanent=0x7fffffffd7f4) at variable.c:159
    159         VALUE path = Qnil;
    (gdb) n
    162         if (!klass) klass = rb_cObject;
    (gdb) n
    163         *permanent = 1;
    (gdb) n
    164         if (RCLASS_IV_TBL(klass)) {
    (gdb) n
    195         return find_class_path(klass, (ID)0);
    (gdb) p find_class_path(klass, (ID)0)
    $1 = 93825001081560

今度は `find_class_path()` は `nil` でない何かを戻す。

オブジェクトの型を確認。

    (gdb) p ((struct RBasic *)find_class_path(klass, (ID)0))->flags&0x1f
    $2 = 5


-   `5` とは
    -   `RUBY_T_STRING = 0x05`
    -   つまり文字列
    -   内容確認

            (gdb) p *(struct RString *)((struct RBasic *)find_class_path(klass, (ID)0))
            $4 = {basic = {flags = 546326565, klass = 93824997250640}, as = {heap = {len = 65, ptr = 0x0, aux = {capa = 0, shared = 0}},
                ary = "A", '\000' <repeats 22 times>}}
    -   つまり文字列 "A"

`find_class_path()` にステップイン。

さらに前述の `fc_i()` でブレーク。 `fc_i()` の定義は以下。

    static int
    fc_i(st_data_t k, st_data_t v, st_data_t a)
    {
        ID key = (ID)k;
        rb_const_entry_t *ce = (rb_const_entry_t *)v;
        struct fc_result *res = (struct fc_result *)a;
        VALUE value = ce->value;
        if (!rb_is_const_id(key)) return ST_CONTINUE;

        if (value == res->klass && (!res->preferred || key == res->preferred)) {
            res->path = fc_path(res, key);
            return ST_STOP;
        }
        if (RB_TYPE_P(value, T_MODULE) || RB_TYPE_P(value, T_CLASS)) {
            if (!RCLASS_CONST_TBL(value)) return ST_CONTINUE;
            else {
                struct fc_result arg;
                struct fc_result *list;

                list = res;
                while (list) {
                    if (list->track == value) return ST_CONTINUE;
                    list = list->prev;
                }

                arg.name = key;
                arg.preferred = res->preferred;
                arg.path = 0;
                arg.klass = res->klass;
                arg.track = value;
                arg.prev = res;
                st_foreach(RCLASS_CONST_TBL(value), fc_i, (st_data_t)&arg);
                if (arg.path) {
                    res->path = arg.path;
                    return ST_STOP;
                }
            }
        }
        return ST_CONTINUE;
    }

`Object` にはコンストが多数定義されているので `fc_i()` は何度も実行される。
`value == res->klass` のとき `key` を `fc_path()` に渡しモジュールパスを得てループを抜ける。

`fc_path(res, key)` の中では `rb_id2str(key)` を呼び、 `global_symbols.id_str` テーブルから `id` に対する文字列を探す。

そうして "A" が戻っていく。

まとめると `a=Module.new;A=a;puts a.name` の `a.name` は Object のコンストテーブルを参照し "A" を得ている。
