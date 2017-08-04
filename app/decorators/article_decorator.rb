# -*- coding: utf-8 -*-
class ArticleDecorator < Draper::Decorator
  delegate_all

  def tagged_content(user_id)
    sentence_arr = object.content.sentence.split(/\s/)
    analysis_text = ""
    object.analysis_content.content_arr.each do |analysis_arr|
      analysis_text += '<p class=uk-article-lead>'
      analysis_arr.each do |analysis_word|
        # 各単語に対するクラス情報の付与
        if ". , 's ? !".include?(analysis_word[0])
          analysis_text += analysis_word[0]
        else
          # スラッシュ情報の追可(前置詞の直前)
          analysis_text += "<span class='slash slash-inactive'> /</span>" if analysis_word[1] == 'IN'
          # 単語の既知未知 情報の追加
          class_text = "word #{analysis_word[0].downcase} #{analysis_word[1]}"
          word_history = WordHistory.find_by(user_id: user_id, spell: analysis_word[0].downcase)
          if word_history.nil? || word_history.is_known
            class_text += " known"
          else
            class_text += " unknown"
          end
          # 品詞の応じたクラス付け
          ## 品詞の大分類に応じて処理を変更
          case TreeTagger.judge_pos(analysis_word[1])
          ### 名詞
          when 'noun'; class_text += " pos noun-pos-inactive"
          ### 動詞
          when 'verb'; class_text += " pos verb-pos-inactive"
          ### 形容詞
          when 'adj'; class_text += " pos adj-pos-inactive"
          end

          analysis_text += "<span class='#{class_text}'> "
          analysis_text += analysis_word[0]
          analysis_text += "</span>"
        end
      end
      analysis_text += '</p>'
    end
    analysis_text
  end
  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  #   def created_at
  #     helpers.content_tag :span, class: 'time' do
  #       object.created_at.strftime("%a %m/%d/%y")
  #     end
  #   end

end
