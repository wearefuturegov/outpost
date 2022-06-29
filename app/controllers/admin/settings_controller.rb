class Admin::SettingsController < Admin::BaseController

      def edit 
        @admin_settings = Form::AdminSettings.new
      end

      def update

        @admin_settings = Form::AdminSettings.new(setting_params)

        if @admin_settings.save
          redirect_to edit_admin_settings_path(@admin_settings), notice: "Settings have been saved."
        else
          render :edit
        end

      end
  
      private
        def setting_params
          params.require(:form_admin_settings).permit(*Form::AdminSettings::KEYS)
        end
end