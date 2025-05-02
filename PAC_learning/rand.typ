#set page(margin: 1in)
#set par(leading: 0.55em, first-line-indent: 1.8em, justify: true)
//#set text(font: "New Computer Modern")
#set text(font: "Noto Serif CJK JP") // 本文のフォント指定

#set par(spacing: 0.55em)
#show heading: set block(above: 1.4em, below: 1em)


//タイトル・見出しフォント//
#set heading(numbering: "1.")
#let heading_font(body) = {
  body
}
#show heading: heading_font


//表のキャプション位置の指定//
#show figure.where(
  kind: table
): set figure.caption(position: top)

//equationに番号を振る//
#set math.equation(numbering: "(1)")
//bar設定//
#let bar(x) = $macron(#x)$

#align(center, text(20pt)[
  #heading_font[2025-先端プログラミング言語特論
  
  課題　乱数生成]
])
#align(center, text(14pt)[
  #heading_font[安部 新司 J2200005]
])

= 一様乱数の生成
- $a <b$ なる定数$a,b$に対して、一様乱数$U(a,b)$は次のような確率密度関数を持つ確率分布である：
$
  p(x) colon.eq cases(
    1/(b-a)  "if" x in [a,b],
    0 space space space "if" x in.not [a,b]
  )
$
- $U(-1,+1)$の確率密度関数を図示すると次のようになる:

== 演習110
一様分布$U(-1,+1)$に従う乱数を10,000点生成し、下の図のように、その頻度分布を確率密度関数と重ねてプロットしろ。

= 正規乱数の生成
平均 $m$,分散 $sigma^2$ の正規分布を$N$