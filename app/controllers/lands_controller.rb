class LandsController < ApplicationController
  before_action :set_land, only: %i[ show edit update destroy ]

  # GET /lands or /lands.json
  def index
    @lands = Land.all.order(price_per_acre: :asc)
  end

  def scrape
    url = 'https://www.landwatch.com/utah-land-for-sale/'
    response = LandSpider.process(url)
    if response[:status] == :completed && response[:error].nil?
      flash.now[:notice] = 'Successfully scraped url'
    else
      flash.now[:alert] = response[:error]
    end
  end

  # GET /lands/1 or /lands/1.json
  def show; end

  # GET /lands/new
  def new
    @land = Land.new
  end

  # GET /lands/1/edit
  def edit; end

  # POST /lands or /lands.json
  def create
    @land = Land.new(land_params)

    respond_to do |format|
      if @land.save
        format.html { redirect_to land_url(@land), notice: 'Land was successfully created.' }
        format.json { render :show, status: :created, location: @land }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @land.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /lands/1 or /lands/1.json
  def update
    respond_to do |format|
      if @land.update(land_params)
        format.html { redirect_to land_url(@land), notice: 'Land was successfully updated.' }
        format.json { render :show, status: :ok, location: @land }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @land.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /lands/1 or /lands/1.json
  def destroy
    @land.destroy

    respond_to do |format|
      format.html { redirect_to lands_url, notice: 'Land was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def datatable
    requested_length = params[:length].to_i
    requested_start  = params[:start].to_i

    sort_col = params['order']['0']['column'] # eg 0 for column 0
    sort_dir = params['order']['0']['dir'] # 'desc' or 'asc'
    sort_name = params['columns'][sort_col]['name'] # the column name set in the data table initialization. MUST equal the DB column name
    search_value = params['search']['value']

    return unless %w[id site price acreage price_per_acre city state county landwatch_id].include? sort_name

    filtered_count = Land.all.size
    records = Land.all
                  .order(sort_name => sort_dir)
                  .limit(requested_length)
                  .offset(requested_start)

    ActiveRecord::Base.include_root_in_json = false

    payload = {
      draw: params[:draw],
      recordsTotal: Land.all.size,
      recordsFiltered: filtered_count,
      data: records
    }

    render json: payload, status: :ok
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_land
    @land = Land.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def land_params
    params.require(:land).permit(:site, :site_path, :price)
  end
end
