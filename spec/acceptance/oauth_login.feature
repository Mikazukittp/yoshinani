# language: ja
@user @oauth
機能: ユーザーとしてOAuth登録する
  ユーザとしてOAuth経由で登録したい
  なぜならば、通常よりも認証が楽だからだ

  シナリオ: OAuth登録をした後、会員情報を入力する
    前提 次のSNSが登録されている:
      | SNS名            |
      | Facebook         |


    かつ 'Facebook' のOAuth経由で新規会員登録を行う
    かつ 次の情報でユーザー情報の更新を行う
      | アカウント | メールアドレス      | ユーザネーム | パスワード |
      | fb_user    | fb_user@example.com | fb_user      | fb_user123 |

    ならば ユーザー 'fb_user' パスワード 'fb_user123' としてログインできること
