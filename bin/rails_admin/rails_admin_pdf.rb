module RailsAdminPdf
end

require 'rails_admin/config/actions'
require 'prawn'
require 'gruff'

module RailsAdmin
  module Config
    module Actions
      class Pdf &lt; Base RailsAdmin::Config::Actions.register(self) register_instance_option :member do true end register_instance_option :pjax? do false end register_instance_option :controller do Proc.new do # Configurando PDF PDF_OPTIONS = { :page_size =&gt; "A4",
              :page_layout => :portrait,
              :margin      => [40, 75]
            }

            # Configurando Retorno
            ramdom_file_name = (0...8).map { (65 + rand(26)).chr }.join

            Prawn::Document.new(PDF_OPTIONS) do |pdf|
              pdf.fill_color "666666"
              pdf.text "Relatório do Representante", :size =&gt; 32, :style =&gt; :bold, :align =&gt; :center
              pdf.move_down 80

              pdf.text "Dados Pessoais", :size =&gt; 14, :align =&gt; :justify, :inline_format =&gt; true, :style =&gt; :bold
              pdf.move_down 14

              if @object.name
                pdf.text "Nome: #{@object.name}", :size =&gt; 12, :align =&gt; :justify, :inline_format =&gt; true
                pdf.move_down 8
              end

              if @object.document
                pdf.text "Documento: #{@object.document}", :size =&gt; 12, :align =&gt; :justify, :inline_format =&gt; true
                pdf.move_down 8
              end

              if @object.kind
                pdf.text "Tipo: #{@object.kind}", :size =&gt; 12, :align =&gt; :justify, :inline_format =&gt; true
                pdf.move_down 8
              end

              if @object.status
                pdf.text "Status: #{@object.status}", :size =&gt; 12, :align =&gt; :justify, :inline_format =&gt; true
                pdf.move_down 8
              end

              if @object.email
                pdf.text "Email: #{@object.email}", :size =&gt; 12, :align =&gt; :justify, :inline_format =&gt; true
                pdf.move_down 8
              end

              pdf.move_down 20

              if @object.comissions.where(status: :pending).count &gt; 0

                pdf.text "Comissões Pendentes", :size =&gt; 14, :align =&gt; :justify, :inline_format =&gt; true, :style =&gt; :bold
                pdf.move_down 14

                total = 0

                @object.comissions.where(status: :pending).each do |c|
                  pdf.text "Id #{c.id}, valor R$#{c.value}, gerada em #{c.created_at.strftime("%d/%m/%y as %H:%M")}",
                    :size =&gt; 12, :align =&gt; :justify, :inline_format =&gt; true
                  pdf.move_down 8

                  total += c.value
                end

                pdf.move_down 10
                pdf.text "Total: R$#{total}", :size =&gt; 12, :align =&gt; :justify, :inline_format =&gt; true
                pdf.move_down 20
              end


              if @object.clients.count &gt; 0

                pdf.text "Clientes Ativos", :size =&gt; 14, :align =&gt; :justify, :inline_format =&gt; true, :style =&gt; :bold
                pdf.move_down 14

                total = 0

                @object.clients.each do |c|
                  pdf.text "#{c.name}",
                    :size =&gt; 12, :align =&gt; :justify, :inline_format =&gt; true, :style =&gt; :bold
                  pdf.move_down 8

                  pdf.text "Da empresa: #{c.company_name}",
                    :size =&gt; 12, :align =&gt; :justify, :inline_format =&gt; true
                  pdf.move_down 8

                  pdf.text "Cliente desde #{c.created_at.strftime("%d/%m/%y as %H:%M")}",
                    :size =&gt; 12, :align =&gt; :justify, :inline_format =&gt; true
                  pdf.move_down 8

                  total += 1
                end

                pdf.move_down 10
                pdf.text "Total: #{total}", :size =&gt; 12, :align =&gt; :justify, :inline_format =&gt; true
                pdf.move_down 20
              end


              if @object.sales.count &gt; 0
                # Cria o objeto Gruff
                g = Gruff::Pie.new 900
                g.theme = Gruff::Themes::PASTEL

                # Aqui ele formata nossos dados
                sales_values = {}
                @object.sales.each do |sale|
                  calc = 0
                  sale.product_quantities.each {|p| calc += p.product.price * p.quantity}
                  sales_values[sale.client.name] = (sales_values[sale.client.name])? sales_values[sale.client.name] + calc : calc
                end

                sales_values.each {|key, value| g.data(key, value)}

                # Gera a imagem no diretório público (você pode escolher onde gerar)
                g.write('public/graph.jpg')

                pdf.start_new_page

                pdf.text "Gráfico de Vendas", :size =&gt; 20, :style =&gt; :bold, :align =&gt; :center

                # Incluir o gráfico numero 2
                pdf.image "public/graph.jpg", :scale =&gt; 0.50
              end


              # Muda de font para Helvetica
              pdf.font "Helvetica"
              # Inclui um texto com um link clicável (usando a tag link) no bottom da folha do lado esquerdo e coloca uma cor especifica nessa parte (usando a tag color)
              pdf.text "Link Para o Manul do Prawn clicável", :size =&gt; 10, :inline_format =&gt; true, :valign =&gt; :bottom, :align =&gt; :left
              # Inclui em baixo da folha do lado direito a data e o némero da página usando a tag page
              pdf.number_pages "Gerado: #{(Time.now).strftime("%d/%m/%y as %H:%M")} - Página ", :start_count_at =&gt; 0, :page_filter =&gt; :all, :at =&gt; [pdf.bounds.right - 140, 7], :align =&gt; :right, :size =&gt; 8
              # Gera no nosso PDF e coloca na pasta public com o nome agreement.pdf
              pdf.render_file("public/#{ramdom_file_name}.pdf")
            end

            File.open("public/#{ramdom_file_name}.pdf", 'r') do |f|
              send_data f.read.force_encoding('BINARY'), :filename =&gt; 'pdf', :type =&gt; "application/pdf", :disposition =&gt; "attachment"
            end
            File.delete("public/#{ramdom_file_name}.pdf")
            File.delete("public/graph.jpg") if @object.sales.count &gt; 0
          end
        end

        register_instance_option :link_icon do
          'fa fa-file-pdf-o'
        end
      end
    end
  end
end
