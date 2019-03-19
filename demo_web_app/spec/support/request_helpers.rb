module RequestHelpers
  #################################################################
  # for HTTP
  #################################################################
  # 一覧取得APIテスト共通コードの共通部分抜き出したコード
  shared_examples_for 'response from demo_web_app by http' do |template_resource, assigned_resource|
    it "returns a success response" do
      subject
      expect(response).to have_http_status(:ok)
    end

    it "returns template" do
      is_expected.to render_template(template_resource)
    end

    it "assigned @resource" do
      initial_db
      subject
      expect(assigns(assigned_resource)).to eq resource
    end

    # @lastは listアクションのみチェックする
    it "assigned @last" do
      if :list == template_resource
        initial_db
        subject
        expect(assigns(:last)).to eq last
      end
    end
  end

  #################################################################
  # for JSON
  #################################################################
  # 一覧取得APIテスト共通コードの共通部分抜き出したコード
  shared_examples_for 'response from demo_web_app by json' do |template_resource, assigned_resource|
    it 'returns a success response' do
      subject
      expect(response).to have_http_status(:ok)
    end

    it 'returns template' do
      is_expected.to render_template(template_resource)
    end

    it 'returns json' do
      initial_db
      subject

      json = JSON.parse(response.body)
      expect(json.size).to eq resource.size
      json.each do |v|
        r = resource.shift
        expect(v).to include(JSON.parse(r.to_json))
      end
    end
  end

  #################################################################
  # GET REQUEST select HTTP or JSON
  #################################################################
  # 一覧取得APIテスト共通コード
  shared_examples_for 'get api test' do |select, template_resource, assigned_resource|
    context "without params" do
      let(:param) { { } }
      let(:resource) { [ data1, data2, data3 ] }
      let(:last) { nil }

      it_behaves_like 'response from demo_web_app ' + select, template_resource, assigned_resource do
        let(:initial_db) {
          data1
          data2
          data3
        }
      end
    end

    context "with params of date" do
      let(:param) { { date: now.strftime("%Y%m%d") } }
      let(:resource) { [ data2 ] }
      let(:last) { nil }

      it_behaves_like 'response from demo_web_app ' + select, template_resource, assigned_resource do
        let(:initial_db) {
          data1
          data2
          data3
        }
      end
    end

    context "with params of from to" do
      let(:param) { { from: (now - 1.second).strftime("%Y%m%d%H%M%S"), to: (now + 1.second).strftime("%Y%m%d%H%M%S") } }
      let(:resource) { [ data5, data6, data7 ] }
      let(:last) { nil }

      it_behaves_like 'response from demo_web_app ' + select, template_resource, assigned_resource do
        let(:initial_db) {
          data4
          data5
          data6
          data7
          data8
        }
      end
    end

    context "with params of both from to and date" do
      let(:param) { { data: now.strftime("%Y%m%d"), from: (now - 1.second).strftime("%Y%m%d%H%M%S"), to: (now + 1.second).strftime("%Y%m%d%H%M%S") } }
      let(:resource) { [ data5, data6, data7 ] }
      let(:last) { nil }

      it_behaves_like 'response from demo_web_app ' + select, template_resource, assigned_resource do
        let(:initial_db) {
          data4
          data5
          data6
          data7
          data8
        }
      end
    end

    context "with params of invalid date" do
      let(:param) { { date: now.strftime("%Y%m99") } }
      let(:resource) { [ data1, data2, data3 ] }
      let(:last) { nil }

      it_behaves_like 'response from demo_web_app ' + select, template_resource, assigned_resource do
        let(:initial_db) {
          data1
          data2
          data3
        }
      end
    end

    context "with params of invalid from and valid to" do
      let(:param) { { from: (now - 1.second).strftime("%Y%m%d%H%M99"), to: (now + 1.second).strftime("%Y%m%d%H%M%S") } }
      let(:resource) { [ data4, data5, data6, data7, data8 ] }
      let(:last) { nil }

      it_behaves_like 'response from demo_web_app ' + select, template_resource, assigned_resource do
        let(:initial_db) {
          data4
          data5
          data6
          data7
          data8
        }
      end
    end

    context "with params of valid from and invalid to" do
      let(:param) { { from: (now - 1.second).strftime("%Y%m%d%H%M%S"), to: (now + 1.second).strftime("%Y%m%d%H%M99") } }
      let(:resource) { [ data4, data5, data6, data7, data8 ] }
      let(:last) { nil }

      it_behaves_like 'response from demo_web_app ' + select, template_resource, assigned_resource do
        let(:initial_db) {
          data4
          data5
          data6
          data7
          data8
        }
      end
    end

    # DBデータと一致しない日付を設定する
    context "with params out of data" do
      let(:param) { { date: now.since(2.days).strftime("%Y%m%d") } }
      let(:resource) { [ ] }
      let(:last) { data3 }

      it_behaves_like 'response from demo_web_app ' + select, template_resource, assigned_resource do
        let(:initial_db) {
          data1
          data2
          data3
        }
      end
    end

    # DBデータ範囲外のFrom Toを設定する
    context "with params out of from and to" do
      let(:param) { { from: now.since(5.second).strftime("%Y%m%d%H%M%S"), to: now.since(5.second).strftime("%Y%m%d%H%M%S") } }
      let(:resource) { [ ] }
      let(:last) { data8 }

      it_behaves_like 'response from demo_web_app ' + select, template_resource, assigned_resource do
        let(:initial_db) {
          data4
          data5
          data6
          data7
          data8
        }
      end
    end
  end

  # 測定グループ表示ページ用共通テストコード
  shared_examples_for 'get group page test' do |select, template_resource, assigned_resource|
    context "without id" do
      let(:param) { }
      let(:resource) { [ dataB ] }

      it_behaves_like 'response from demo_web_app ' + select, template_resource, assigned_resource do
        let(:initial_db) {
          dataA
          dataB
        }
      end
    end

    context "with id" do
      let(:param) { dataA.id }
      let(:resource) { [ dataA ] }

      it_behaves_like 'response from demo_web_app ' + select, template_resource, assigned_resource do
        let(:initial_db) {
          dataA
          dataB
        }
      end
    end

    context "with invalid id" do
      let(:param) { dataC.id + 1 }
      let(:resource) { [ dataB ] }

      it_behaves_like 'response from demo_web_app ' + select, template_resource, assigned_resource do
        let(:initial_db) {
          dataA
          dataB
          dataC
        }
      end
    end

    context "with valid id but other machine" do
      let(:param) { dataC.id }
      let(:resource) { [ dataB ] }

      it_behaves_like 'response from demo_web_app ' + select, template_resource, assigned_resource do
        let(:initial_db) {
          dataA
          dataB
          dataC
        }
      end
    end
  end

  #################################################################
  # POST REQUEST
  #################################################################
  # 一覧取得APIテスト共通コード
  shared_examples_for 'post api test' do |model, size|
    context "正常系" do
      it "データが作成される" do
        expect { subject }.to change(model, :count).by(size)
      end
      it "201を返す" do
        subject
        expect(response).to have_http_status(:created)
      end
      it "レスポンスのtypeが一致する" do
        subject
        json = JSON.parse(response.body)

        expect(json["type"]).to eq data[:type]
      end
      it "登録データが一致する" do
        subject
        json = JSON.parse(response.body)

        expect(json["item"]["data"].size).to eq data[:item][:data].size

        json["item"]["data"].each do |v|
          r = data[:item][:data].shift

          expect(v).to include(JSON.parse(r.to_json))
        end
      end
    end
  end

  #################################################################
  # DELETE REQUEST
  #################################################################
  # DELETEアクションのテスト共通コードの共通部分抜き出したコード
  shared_examples_for 'delete action test' do |model|
    it "returns a success response" do
      subject
      expect(response).to have_http_status(:found)
    end

    it "redirect to index" do
      is_expected.to redirect_to(redirect_url)
    end

    it "データが削除される" do
      data
      expect { subject }.to change(model, :count).by(-1)
    end
  end

  #################################################################
  # UPDATE REQUEST
  #################################################################
  # UPDATEアクションのテスト共通コードの共通部分抜き出したコード
  shared_examples_for 'update action test' do
    it "returns a success response" do
      data1
      subject
      expect(response).to have_http_status(:found)
    end

    it "redirect to show" do
      data1
      is_expected.to redirect_to(redirect_url)
    end
  end
end
