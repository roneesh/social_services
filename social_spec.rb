require './social'

describe GoogleData, "#symbolize" do
  google_data = GoogleData.new("http://josh.jones-dilworth.com/post/61542844541/book-worth-reading-contagious")
  it "returns its service name a symbol" do
    expect(google_data.symbolize).to eq(:google)
  end
end

describe GoogleData, "#shares" do
  google_data = GoogleData.new("http://josh.jones-dilworth.com/post/61542844541/book-worth-reading-contagious")
  bad_data = GoogleData.new("not_a_url")
  
  it "returns a Fixnum plus count" do
    expect(google_data.shares).to be_a(Fixnum)
  end

  it "returns a SocialData::RequestFailure error when not given a valid url" do
    expect { bad_data.shares }.to raise_error(SocialData::RequestFailure)
  end

end
