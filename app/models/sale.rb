class Sale < ApplicationRecord
  belongs_to :client
  belongs_to :user
  belongs_to :discount
  has_many :product_quantities
  has_one :comission

  after_save do
    calc = 0
    # Soma o preço dos produtos vezes a quantidade deles
    self.product_quantities.each {|p| calc += p.product.price * p.product.quantity}

    # Verifica se existe um desconte e aplica caso exista
    if self.discount
      if self.discount.kind == 'porcent'
        calc -= calc / self.discount.value
      elsif self.discount.kind == 'money'
        calc -= self.discount.value
      end
    end
  end

end
