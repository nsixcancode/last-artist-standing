describe "PasswordResets" do
  describe "GET /password_resets/new" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get '/password_resets/new'
      response.status.should be(200)
    end
  end
end
