#　生命情報科学キャッチアップ資料
## これは何
生命情報科学界隈で知らないとモグリだけど常識なので誰も教えてくれないし検索ワードもよく分からない諸々のメモ  
随時追記  
調べ方として、機械学習分野の方からではなくバイオインフォマティクス分野のほうから攻めるとよかった  
機械学習アルゴリズムは当然ながら機械学習分野で調べるべきだが、前処理の段階ではバイオインフォから行くほうがよさそう  

# データセット準備の準備
#### 論文だとデータを頑張って加工したと書いてあるが、結局生データどこやねんとなる問題 

論文投稿時に利用したシーケンスデータの公開が原則的に義務化されている。引用あたりにデータセットの登録番号（アクセッション番号）が書いてあるのでそれを見る。結構たらい回しにされるので存在を知らないとたどり着かないと思う。あまりにたらい回しにされるので、研究倫理研修とか受けないとアクセスに制限があるのでは？と思っていたが、ほとんどのデータは誰でも見れるので根気よくリンクをたどる。一昔前の違法ダウンロード全盛期を思い出す（最悪）
Human Cell AtlasのHCA Data Repositoryは一部制限アクセスになるらしい。
https://bi.biopapyrus.jp/rnaseq/exp/fastq-data/download-fastq-sra.html
>シーケンサーから得られる FASTQ ファイルは、一般的に論文発表時あるいはその前に DDBJ SRA、NCBI SRA、EMBL-EBI ENA のなどのいずれかのデータベースに登録される。論文中に記載される accession number を元にこれらのデータベースで調べれば、論文の解析に用いたデータを入手することができる。

DBはそれぞれ運営国が違う。データの圧縮形式やメタデータの有無などが異なるが、基本的に同期されるらしいのでどれを使っても良いらしい。それはそれとして番号が一意であったりすべてのDBが統一された番号を使用しているという保証はない。

https://bi.biopapyrus.jp/rnaseq/exp/fastq-data/
>DDBJ SRA、 NCBI SRA、 EMBL-EBI ENA の 3 つのデータベース間ではデータの同期が行われている。同期が遅れている場合を除き、基本的にどのデータベースを利用してもよい。3 つのデータベースでは FASTQ ファイルの配布方法が異なっている。DDBJ SRA は FASTQ ファイルを bzip2 形式で圧縮し配布している。EMBL-EBI ENA は FASTQ ファイルを gz 形式で圧縮し配布している。また、NCBI SRA では FASTQ ファイルメタ情報などを追加した SRA 形式のファイルを配布している。bzip2 および gz 形式で圧縮された FASTQ は、解凍せずにそのまま解析に用いることができる。これに対して、SRA 形式で圧縮されたファイルの場合は、それを展開して FASTQ ファイルを抽出する必要がある。


#### FASTQ形式って何？
#### 生データはわかったけど、このテキストデータをどうやってゲノムっぽくするんですか？
https://illumination-k.dev/techblog/post/da91fbca-0240-45b9-b299-faddaae28346

各種データ形式と変換についてはこれがよくまとまっている。以下いくつかの抜粋。

**fastq**
NGS解析で一番最初に作成されるファイルフォーマット。厳密には画像データが一次データですが、多分シーケンサーを持っていてそこからデータを直接扱っていない限りはこれ以前のファイルは見ないんじゃないんでしょうか。
fastqファイルには、NGSで読まれたリードの名前を示す@から始まるヘッダ行、配列、配列のクオリティが記載されています。また、配列と配列クオリティを分けるために+から始まるヘッダ行が配列と配列クオリティの間に置かれています。fastaフォーマットとは違い、配列、配列クオリティ行内では改行が許されていません。

**fastq sample**
例えばNCBIのSRAに存在するfastqは以下のようなフォーマットになります。  
@SRR001666.1 071112_SLXA-EAS1_s_7:5:1:817:345 length=36  
GGGTGATGGCCGCTGCCGATGGCGTCAAATCCCACC  
+SRR001666.1 071112_SLXA-EAS1_s_7:5:1:817:345 length=36  
IIIIIIIIIIIIIIIIIIIIIIIIIIIIII9IG9IC  
配列には、AGCTNのみが許されており、配列クオリティには、Phredクオリティスコア（下の式）というものが使われています。基本的に高いほどシーケンサーのエラーである可能性が低いです。最近のバージョンではサンガーの式が使われていますが、Wikipediaによるとオッズ比などが使われていることもあるそうです。実際には数字ではなくASCIIコードで33から126の文字としてエンコーディングされます。このエンコーディングはSAM/BAMフォーマットでも共通のものです。
Q=−10log10pQ=−10log10​p
このファイルフォーマットはクオリティコントロール程度にしか使われず、基本的にはSAM/BAMに変換してから扱うことが多い印象です。最近ではRNA-seqなどにはSAM/BAMを介さずそのまま発現量測定などをすることもあります

>注：このままn-gramにしてBERTやるのがDNABERTのアプローチらしい？
>nの数によって異なる生物学的意味合いが生じるため適当に決めるのはよくない

**SAM/BAM/CRAM**
マッピングを行ったあと扱うようになるファイルフォーマットです。BAMはSAMをバイナリ化したものでフォーマットとしては同一です。CRAMはfasta情報を使って更に圧縮率を上げることができるフォーマットです。あまりSAMのまま扱うことはなく、BAM/CRAMに変換されることが多いです。リードのヘッダ、配列、クオリティ、マッピング位置などほぼすべての情報が格納されている。

**SAM sample**
例としてはこんな感じです。@から始まるヘッダ行とリードの情報が格納されているボディ部分に分かれています。

@HD VN:1.6 SO:coordinate  
@SQ SN:ref LN:45  
r001 99 ref 7 30 8M2I4M1D3M = 37 39 TTAGATAAAGGATACTG *  
r002 0 ref 9 30 3S6M1P1I4M * 0 0 AAAAGATAAGGATA *  
r003 0 ref 9 30 5S6M * 0 0 GCCTAAGCTAA * SA:Z:ref,29,-,6H5M,17,0;  
r004 0 ref 16 30 6M14N5M * 0 0 ATAGCTTCAGC *  
r003 2064 ref 29 17 6H5M * 0 0 TAGGC * SA:Z:ref,9,+,5S6M,30,1;  
r001 147 ref 37 30 9M = 7 -39 CAGCGGCAT * NM:i:1  

シーケンサで読んだゲノムがリファレンスゲノムのどの部分に当たるかをマッピングしたデータ

**発現量の定量 (bam -> csv etc.,)**
RNA-seqを行った後に行う代表的な解析は、発現量の定量です。ツールとしては色々ありますが、代表的そうなものを紹介します。cuffdiffなんかは有名ですが使用は推奨されていないようです。

>注：stempantoxで頂いているデータはこれ？
>CSVに持っていくまでがかなり苦しいので、既存データセットを利用しない論文のかなりのウェイトがデータセット作成に置かれている気持ちを理解

## データの扱いに慣れる
https://medium.com/@manabeel.vet/a-beginners-guide-to-genomic-data-analysis-dive-into-genomic-data-collection-with-ncbi-datasets-3d3f47dfd7cf  
線虫（扱いやすさと規模の小ささから神経発達についてのモデル生物）のゲノムを用いて一通りのゲノムデータ分析を行うチュートリアル  
直接的に機械学習には関係しないが、データに慣れるための実践にはこれが良さそう　現在追走中  　

# その他リンク
https://bi.biopapyrus.jp/

# 全く関係ない論文紹介紹介
言語モデルの物理学　佐藤 竜馬  
https://joisino.hatenablog.com/entry/physics  
「物理法則のような普遍的な法則を言語モデルにおいて見つけるための研究」を物理学実験のように条件を整えて実験を行い観察することで行おう、というもの  
具体的には、コントロールされたデータセットを用い、都度内部状態を調査する  

我々に関連しそうなトピック：
- 事前訓練時に同じ情報を様々な方法で表現したテキストを用いることで精度が向上する
- 言語モデルは貯蔵した形でしか知識を抽出できない
- 言語モデルは逆検索ができない
- １パラメータあたり2ビットの情報を記録できる
- int8量子化をしても記憶容量は下がらないがint4量子化をすると記憶効率が下がる