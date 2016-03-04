# language: ja

@user @payment
機能: ユーザーとして支払情報を削除する
  ユーザーとして支払情報を削除したい
  なぜならば、情報に間違いがあるケースがあるからだ

  シナリオ: 支払いを削除した場合は、自分、参加者の支払い情報も更新される
    前提 次のユーザーが登録されている:
      | アカウント               | パスワード    | メールアドレス  |
      | paid_user                | password12345 | ex1@example.com |
      | participants1            | password12345 | ex2@example.com |
      | participants2            | password12345 | ex3@example.com |

    かつ 次のグループが登録されている:
      | グループ名               | 説明       |
      | フリーメイソン           | 天才ばっか |

    かつ ユーザー 'paid_user' はグループ 'フリーメイソン' に所属している
    かつ ユーザー 'participants1' はグループ 'フリーメイソン' に所属している
    かつ ユーザー 'participants2' はグループ 'フリーメイソン' に所属している

    かつ ユーザー 'paid_user' パスワード 'password12345' としてログインする

    かつ 次の支払情報を登録する
     | 金額  | イベント         | 説明 | 日付       | 参加者                      | グループ名     |
     | 20000 | hogehogeイベント | hoge | 2015-10-15 | participants1,participants2 | フリーメイソン |

    かつ 'hogehogeイベント' の支払情報を削除する

    ならば ユーザー 'participants1' の立替えされた金額が '0.0' になっていること
