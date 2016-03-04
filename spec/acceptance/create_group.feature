# language: ja
@user @group
機能: ユーザーとしてグループを新規作成する
  ユーザとしてグループを新しく作りたい
  なぜならば、グループを新規作成してその中で金銭の管理をしたいからだ

  シナリオ: グループを作成した場合、そのグループに自分が参加した状態になっている
    前提 次のユーザーが登録されている:
      | アカウント               | パスワード    |
      | hogehoge                 | password12345 |

    かつ ユーザー 'hogehoge' パスワード 'password12345' としてログインする

    かつ 次のグループを作成する
      | グループ名         | 説明     |
      | ふんばり温泉チーム | 木刀の竜 |

    ならば ユーザー 'hogehoge' はグループ 'ふんばり温泉チーム' に参加していること
