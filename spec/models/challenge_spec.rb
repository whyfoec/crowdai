require 'rails_helper'

describe Challenge do
  context 'fields' do
    it { is_expected.to respond_to :challenge }
    it { is_expected.to respond_to :status_cd }
    it { is_expected.to respond_to :description }
    it { is_expected.to respond_to :evaluation_markdown }
    it { is_expected.to respond_to :rules }
    it { is_expected.to respond_to :prizes }
    it { is_expected.to respond_to :resources }
    it { is_expected.to respond_to :dataset_description }
    it { is_expected.to respond_to :submission_instructions }
    it { is_expected.to respond_to :tagline }
    it { is_expected.to respond_to :evaluation }
    it { is_expected.to respond_to :primary_sort_order_cd }
    it { is_expected.to respond_to :secondary_sort_order_cd }
    it { is_expected.to respond_to :description_markdown }
    it { is_expected.to respond_to :rules_markdown }
    it { is_expected.to respond_to :prizes_markdown }
    it { is_expected.to respond_to :resources_markdown }
    it { is_expected.to respond_to :dataset_description_markdown }
    it { is_expected.to respond_to :submission_instructions_markdown }
    it { is_expected.to respond_to :perpetual_challenge }
    it { is_expected.to respond_to :grading_factor }
    it { is_expected.to respond_to :grader_cd }
    it { is_expected.to respond_to :answer_file_s3_key }
    it { is_expected.to respond_to :page_views }
    it { is_expected.to respond_to :license }
    it { is_expected.to respond_to :license_markdown }
    it { is_expected.to respond_to :participant_count }
    it { is_expected.to respond_to :submission_count }
    it { is_expected.to respond_to :score_title }
    it { is_expected.to respond_to :automatic_grading }
    it { is_expected.to respond_to :slug }
    it { is_expected.to respond_to :submission_license }
    it { is_expected.to respond_to :score_secondary_title }
    it { is_expected.to respond_to :daily_submissions }
    it { is_expected.to respond_to :threshold }
    it { is_expected.to respond_to :media_on_leaderboard }
    it { is_expected.to respond_to :vote_count }
    it { is_expected.to respond_to :image_file }
    it { is_expected.to respond_to :featured_sequence }
    it { is_expected.to respond_to :dynamic_content_flag }
    it { is_expected.to respond_to :dynamic_content_tab}
    it { is_expected.to respond_to :dynamic_content}
    it { is_expected.to respond_to :winner_description_markdown }
    it { is_expected.to respond_to :winner_description }
    it { is_expected.to respond_to :winners_tab_active }
  end

  context 'associations' do
    it { is_expected.to belong_to(:organizer) }
    it { is_expected.to have_many(:dataset_files) }
    it { is_expected.to have_many(:submission_file_definitions) }
    it { is_expected.to accept_nested_attributes_for :submission_file_definitions }
    it { is_expected.to have_many(:submissions) }
    it { is_expected.to have_many(:leaderboards) }
    it { is_expected.to have_many(:ongoing_leaderboards) }
    it { is_expected.to have_many(:participant_challenges) }
    it { is_expected.to have_many(:topics) }
    it { is_expected.to have_many(:votes) }
    it { is_expected.to have_many(:follows) }
    it { is_expected.to have_many(:challenge_rounds) }
  end

  describe 'indexes' do
    it { is_expected.to have_db_index ["organizer_id"] }
  end

=begin
  context 'validations' do
    it { is_expected.to validate_presence_of(:challenge) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_presence_of(:organizer_id) }
    it { is_expected.to validate_presence_of(:grader) }
    it { is_expected.to validate_presence_of(:primary_sort_order) }
    it { is_expected.to validate_presence_of(:grading_factor) }
  end
=end
  context 'methods' do
    describe 'validate markdown fields' do
      let(:challenge) { create :challenge }
      it 'description' do
        challenge.update!(description_markdown: '### The description')
        expect(challenge.description).to eq("<h3 id=\"the-description\">The description</h3>\n")
      end
      it 'evaluation' do
        challenge.update!(evaluation_markdown: '# An evaluation')
        expect(challenge.evaluation).to eq("<h1 id=\"an-evaluation\">An evaluation</h1>\n")
      end
      it 'rules' do
        challenge.update!(rules_markdown: "Some *rules*")
        expect(challenge.rules).to eq("<p>Some <em>rules</em></p>\n")
      end
      it 'prizes' do
        challenge.update!(prizes_markdown: "# Prizes are described here.")
        expect(challenge.prizes).to eq("<h1 id=\"prizes-are-described-here\">Prizes are described here.</h1>\n")
      end
      it 'resources' do
        challenge.update!(resources_markdown: "# Helpful resources")
        expect(challenge.resources).to eq("<h1 id=\"helpful-resources\">Helpful resources</h1>\n")
      end
      it 'dataset_description' do
        challenge.update!(dataset_description_markdown: "# Dataset description")
        expect(challenge.dataset_description).to eq("<h1 id=\"dataset-description\">Dataset description</h1>\n")
      end
      it 'submission_instructions' do
        challenge.update!(submission_instructions_markdown: "## Submission instructions")
        expect(challenge.submission_instructions).to eq("<h2 id=\"submission-instructions\">Submission instructions</h2>\n")
      end
      it 'winner_description' do
        challenge.update!(winner_description_markdown: '## A Winner!')
        expect(challenge.winner_description).to eq("<h2 id=\"a-winner\">A Winner!</h2>\n")
      end
    end

    describe 'after_initialize' do
      it 'sets submission information defaults' do
        challenge = create(:challenge)
        expect(challenge.submission_license).to eq("Please upload your submissions and include a detailed description of the methodology, techniques and insights leveraged with this submission. After the end of the challenge, these comments will be made public, and the submitted code and models will be freely available to other crowdAI participants. All submitted content will be licensed under Creative Commons (CC).")
        expect(challenge.daily_submissions).to eq(5)
      end
    end


    describe '#record_page_view' do
      it 'returns 1 for the first view' do
        article = build(:article)
        article.record_page_view
        expect(article.view_count).to eq(1)
      end

      it 'returns 3 for the third view' do
        article = build(:article)
        3.times { article.record_page_view }
        expect(article.view_count).to eq(3)
      end
    end

    describe '#valid_status' do
      #it 'does not allow a challenge to be running without dataset files' do
      #  challenge = create(:challenge)
      #  expect {
      #    challenge.update!(status: :running)
      #  }.to raise_error(ActiveRecord::RecordInvalid)
      #end

      it 'prevents a draft challenge being cancelled' do
        challenge = create(:challenge, :draft)
        expect {
          challenge.update!(status: :cancelled)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it 'prevents a completed challenge being cancelled' do
        challenge = create(:challenge, :draft)
        expect {
          challenge.update!(status: :completed)
          challenge.update!(status: :cancelled)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    describe "friendly_id" do
      it 'updates the slug when the challenge title changes' do
        challenge = create(:challenge)
        challenge.challenge = 'a new challenge title'
        challenge.save!
        expect(challenge.slug).to eq('a-new-challenge-title')
      end
    end

    describe '#current_round' do
      context 'single open round' do
        let(:challenge) { create :challenge, :running }
        it { expect(challenge.current_round.round_status_cd).to eq('current') }
        it { expect(challenge.current_round.active).to be true }
        it { expect(challenge.current_round.challenge_id).to eq(challenge.id) }
      end
      context 'previous and current round' do
        let(:challenge) { create :challenge, :previous_round }
        it { expect(challenge.current_round.round_status_cd).to eq('current') }
        it { expect(challenge.current_round.active).to be true }
        it { expect(challenge.current_round.challenge_id).to eq(challenge.id) }
      end
    end

    describe '#round_open?' do
      context 'single open round' do
        let(:challenge) { create :challenge, :running }
        it { expect(challenge.round_open?).to be true }
      end
      context 'previous and current round' do
        let(:challenge) { create :challenge, :previous_round }
        it { expect(challenge.round_open?).to be true }
      end
    end

    describe '#previous_round' do
      context 'single open round' do
        let(:challenge) { create :challenge, :running }
        it { expect(challenge.previous_round).to be_nil }
      end
      context 'previous and current round' do
        let(:challenge) { create :challenge, :previous_round }
        it { expect(challenge.previous_round.challenge_round).to eq('round 1') }
        it { expect(challenge.current_round.challenge_round).to eq('round 2') }
      end
    end

  end
end
