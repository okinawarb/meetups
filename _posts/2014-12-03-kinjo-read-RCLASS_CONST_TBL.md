---
layout: default
title: "コンストテーブルの参照 @libkinjo"
date: 2014-12-03
categories: no121
---
## [@libkinjo](https://twitter.com/libkinjo)

`<2014-11-02 Sun>` のときに `Module#name` がどのようにモジュールの名前を解決しているか確認した。

`Module#name` はモジュール名の探索のためにコンストテーブルを参照した。

本件はコンストテーブルの構造を確認する。 <del>また、コンストテーブルの構造を gdb で確認する。</del>

以下 **Ruby Under a Microscope** より

そもそもコンストとは

-   RClass 構造に追加されてるナニ

RClass 構造は Ruby クラスを表現しており、 Ruby クラスとはそもそも

-   Ruby オブジェクトである
-   メソッド定義を含む
-   アトリビュート名を含む
-   スーパークラスのポインタを含む
-   コンストテーブルを含む
-   言語の基礎

RClass 構造の構成要素をメモ

-   method table
-   constant table
-   instance-level attribute names
-   class-level instance variables
-   class pointer
-   superclass

まとめると、コンストとは各 RClass 構造に含まれたコンストテーブルのエントリ。

コンストテーブルの構造という本題。

`<2014-11-02 Sun>` のとき `RCLASS_CONST_TBL` なる記述が各所にあり。

例えば以下。

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

`RCLASS_CONST_TBL` の定義は以下。

    ./internal.h:#define RCLASS_CONST_TBL(c) (RCLASS_EXT(c)->const_tbl)

`RCLASS_EXT` の定義は、

    #define RCLASS_EXT(c) (RCLASS(c)->ptr)

**Ruby Under a Microscope** のとおり `RClass` に `const_tbl` なるメンバが存在。

`const_tbl` な定義を確認。

そのまえに `RClass` な定義を確認。

`RCLASS` の定義

    ./include/ruby/ruby.h:#define RCLASS(obj)  (R_CAST(RClass)(obj))

`RClass` の定義

`include/ruby/ruby.h`

    struct RClass {
        struct RBasic basic;
        VALUE super;
        rb_classext_t *ptr;
        struct method_table_wrapper *m_tbl_wrapper;
    };

`rb_classext_t` の定義

`include/ruby/ruby.h`

    typedef struct rb_classext_struct rb_classext_t;

`rb_classext_struct` の定義

`internal.h`

    struct rb_classext_struct {
        struct st_table *iv_index_tbl;
        struct st_table *iv_tbl;
        struct st_table *const_tbl;
        rb_subclass_entry_t *subclasses;
        rb_subclass_entry_t **parent_subclasses;
        /**
         * In the case that this is an `ICLASS`, `module_subclasses` points to the link
         * in the module's `subclasses` list that indicates that the klass has been
         * included. Hopefully that makes sense.
         */
        rb_subclass_entry_t **module_subclasses;
        rb_serial_t class_serial;
        VALUE origin;
        VALUE refined_class;
        rb_alloc_func_t allocator;
    };

`st_table` は **Ruby Under a Microscope** によると Ruby におけるハッシュテーブルの実装とのこと。

**Ruby Under a Microscope** においては **Chapter 7** に解説あり。

ざっと読む


-   Ruby 1.9 や 2.0 では ivptr はシンプルなアレイだった模様
    -   新しい値を追加するのは速かったけど 3 番目や 4 番目のインスタンスを保存するのは遅かった
    -   巨大なアレイをアロケートしていた
-   ハッシュテーブルは自動的に拡張できる
    -   変数のためにどのていどアロケートすべきかもう考えなくていいとか
-   Saving a Value in Hash Table
    -   構成要素
        -   RHash
            ハッシュテーブルを使う側のこと？
        -   struct st\_table
                  ハッシュテーブルのヘッダ。ハッシュテーブルの基本的な情報を格納。 bins フィールドは bins のポインタ
        -   bins
            ハッシュテーブル本体。エントリのポインタのリスト。 Ruby 1.8 と 1.9 では初期で 11 個の bins が用意。
        -   st\_table\_entry
                  値（エントリ）。ハッシュテーブルからポイントされる。
    -   以下な一行を実行したときに行われる処理について

            my_hash[:key] = "value"
    -   ハッシュテーブルに保存される st\_table\_entry と呼ばれる新しい構造を作成
    -   エントリは 3 つ目の bins バケット（インデックス 2）に保存されるものとすると
    -   このことは与えられたキーによって決定される

            some_value = internal_hash_function(:key)
    -   some\_value を bins の個数で割ったあまりがハッシュ値
    -   ハッシュ値で bins を参照しエントリ
-   Retrieving a Value from a Hash Table
    -   以下な一行を実行したとき

            my_hash[:key]
    -   キーからハッシュ値を計算

            some_value = internal_hash_function(:key)
    -   some\_value を bins の個数で割ったあまりがハッシュ値
    -   ハッシュ値で bins を参照

ここまで。

Retrieving a Value from a Hash Table の動作確認は宿題。
Saving a Value in Hash Table の動作確認はまたその次。
