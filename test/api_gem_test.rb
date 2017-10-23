require "test_helper"

class ApiGemTest < Minitest::Test
  def setup
    @uri_base = "http://todoable.teachable.tech/api"
    stubs()
    @client = ApiGem::Client.new
  end

  def stubs
    list_id = '642b451e-d6bb-41ed-aaf2-a08ae881c503'
    item_id = '891ed3d4-84d8-493d-b1cc-c524c1a05386'
    stub_request(:post, "#{@uri_base}/authenticate")
      .to_return(:body => {"token": "foo"}.to_json)
    stub_request(:get, "#{@uri_base}/lists")
      .to_return(:body => {lists: [{name: "Something", src: "#{@uri_base}/lists/#{list_id}"}]}.to_json)
    stub_request(:get, "#{@uri_base}/lists/#{list_id}")
      .to_return(:body => {"name"=>"foo 86663", "items"=>[{"name"=>"this be an item", "finished_at"=>nil, "src"=>"#{@uri_base}/lists/#{list_id}/items/#{item_id}"}]}.to_json)
    stub_request(:post, "#{@uri_base}/lists")
      .to_return(:body => '', :status => 201)
    stub_request(:patch, "#{@uri_base}/lists/#{list_id}")
      .to_return(:body => "Something updated", :status => 200)
    stub_request(:delete, "#{@uri_base}/lists/#{list_id}")
      .to_return(:body => '', :status => 204)
    stub_request(:post, "#{@uri_base}/lists/#{list_id}/items")
      .to_return(:body => '', :status => 201)
    stub_request(:put, "#{@uri_base}/lists/#{list_id}/items/#{item_id}/finish")
      .to_return(:body => '', :status => 200)
    stub_request(:delete, "#{@uri_base}/lists/#{list_id}/items/#{item_id}")
      .to_return(:body => '', :status => 204)
  end

  def test_get_all_lists
    response = @client.get_all_lists
    assert_equal 200, response.code
  end

  def test_get_list
    response = @client.create_list({list: {"name": "Urgent Things"}})
    assert_equal 201, response.code
    lists = JSON.parse(@client.get_all_lists)
    src = lists.fetch('lists').first.fetch('src')
    response = @client.get_list(src)
    assert_equal 200, response.code
  end

  def test_create_list
    response = @client.create_list({list: {"name": "Urgent Things"}})
    assert_equal 201, response.code
  end

  def test_update_list
    response = @client.create_list({list: {"name": "Urgent Things"}})
    assert_equal 201, response.code
    lists = JSON.parse(@client.get_all_lists.body)
    src = lists.fetch('lists').first.fetch('src')
    response = @client.update_list(src, {list: {"name": "Urgent Two"}})
    assert_equal 200, response.code
  end

  def test_delete_list
    response = @client.create_list({list: {"name": "Urgent Things"}})
    assert_equal 201, response.code
    lists = JSON.parse(@client.get_all_lists.body)
    src = lists.fetch('lists').first.fetch('src')
    response = @client.delete_list(src)
    assert_equal 204, response.code
  end

  def test_create_item
    response = @client.create_list({list: {"name": "Urgent Things"}})
    assert_equal 201, response.code
    src = JSON.parse(@client.get_all_lists.body).fetch('lists').first.fetch('src')
    response = @client.create_item(src, {item: {name: "feed the cat"}})
    assert_equal 201, response.code
  end

  def test_finish_item
    response = @client.create_list({list: {"name": "Urgent Things"}})
    assert_equal 201, response.code
    src = JSON.parse(@client.get_all_lists.body).fetch('lists').first.fetch('src')
    response = @client.create_item(src, {item: {name: "feed the cat"}})
    assert_equal 201, response.code
    src = JSON.parse(@client.get_list(src).body).fetch('items').first.fetch('src')
    response = @client.finish_item(nil, nil, src)
    assert_equal 200, response.code
  end

  def test_delete_item
    response = @client.create_list({list: {"name": "Urgent Things"}})
    assert_equal 201, response.code
    src = JSON.parse(@client.get_all_lists.body).fetch('lists').first.fetch('src')
    response = @client.create_item(src, {item: {name: "feed the cat"}})
    assert_equal 201, response.code
    src = JSON.parse(@client.get_list(src).body).fetch('items').first.fetch('src')
    response = @client.delete_item(nil, nil, src)
    assert_equal 204, response.code
  end

  def test_that_it_has_a_version_number
    refute_nil ::ApiGem::VERSION
  end

  def test_get_token
    refute_nil @client.get_token
  end
end
