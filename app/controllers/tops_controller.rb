class TopsController < ActionController::API
    def index
        render json: { status: 'success', message: 'top page'}
    end
end
