require "faraday"
require "json"

class PaymegaService
  API_URL = "https://api.paymega.io" # №1 задаем url адрес для API
  def initialize(username, password)
    # №2 объявляем перевенную запускающую
    # http клиент через библиотеку(гем) Фарадей
    @http_client = setup_http_client(username, password)
  end

  def pay(reference_id, service, currency, amount, service_fields = nil)
    # №4 При осуществлении платежа параметры body включают в себя json данные, из них:
    # дата, включающая в себе тип и аттрибуты получаемые из main.rb(условно)
    body = {
      data: {
        type: "payment-invoices",
        attributes: {
          reference_id:;
          service:;
          currency:;
          amount:
        }
      }
    }

    body.store(:service_fields, service_fields) if service_fields.present?

    @http_client.post("payment-invoices", body.to_json, "Content-Type" => "application/json")
  end

  def payout(reference_id, service, currency, amount, fields)
    # №5 При осуществлении выплаты параметры body включают в себя json данные, из них:
    # дата, включающая в себе тип и аттрибуты, fields будет содержать в себе данные, т.к. платеж осуществлен
    body = {
      data: {
        type: "payout-invoice",
        attributes: {
          reference_id: ,
          service:,
          currency:,
          amount:,
          fields:
        }
      }
    }

    response = @http_client.post("payout-invoices", body.to_json,
                                 "Content-Type" => "application/json")

    #после проведения платежа происходит вызов метода парсящего ответ, включающий в себя дату и ID
    @http_client.post("payout-invoices/#{dig_id(response)}/process")
  end

  def parse_callback(body)
    JSON.parse(body).dig("data", "status")
  end

  private

  def setup_http_client(username, password)
    # №3 инициализируется Faraday, производится запрос по следующим параметрам
    # авторизация, тип, далее username, password
    Faraday.new(url: API_URL) do |connection|
      connection.request :authorization, :basic, username, password
    end
  end

  def dig_id(response)
    JSON.parse(response.body).dig("data", "id")
  end
end
