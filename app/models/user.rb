class User < ApplicationRecord
  enum kind: [:salesman, :manager]
  enum status: [:active, :inactive]
  has_many :comissions # muitas comissões
  has_many :addresses # muitos endereços
  has_many :clients # muitos clientes
  has_many :product_quantities # muitas qtdes. prod.
  has_many :sales # muitas vendas
end
