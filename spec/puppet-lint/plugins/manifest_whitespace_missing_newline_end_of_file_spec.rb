# frozen_string_literal: true

require 'spec_helper'

describe 'manifest_whitespace_missing_newline_end_of_file' do
  let(:single_newline_end_of_file_msg) { 'there should be a single newline at the end of a manifest' }

  context 'with fix disabled' do
    context 'with no new line at the end of a manifest' do
      let(:code) do
        'class example { }'
      end

      it 'should detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'should create a error' do
        expect(problems).to contain_error(single_newline_end_of_file_msg).on_line(1).in_column(17)
      end
    end
  end

  context 'with fix enabled' do
    before do
      PuppetLint.configuration.fix = true
    end

    after do
      PuppetLint.configuration.fix = false
    end

    context 'with no new line at the end of a manifest' do
      let(:code) do
        'class example { }'
      end

      it 'should detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'should fix the manifest' do
        expect(problems).to contain_fixed(single_newline_end_of_file_msg).on_line(1).in_column(17)
      end

      it 'should add the final newline' do
        expect(manifest).to eq("class example { }\n")
      end
    end
  end
end
