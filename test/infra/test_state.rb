# frozen_string_literal: true

require "test_helper"
require "sqlite3"
require "infra/example"
require "decider/state"
require "securerandom"

module Infra
  class WrongExpectedVersion < StandardError
    attr_reader :expected, :actual

    def initialize(expected, actual)
      @expected = expected
      @actual = actual

      super()
    end
  end

  class Repository
    def initialize(store:, decider:)
      @store = store
      @decider = decider
    end

    def try_load(key:, etag: nil)
      result = store.execute(<<~SQL, [key])
        SELECT value, etag
        FROM state
        WHERE id = ?
        LIMIT 1
      SQL

      value, current_etag = result.first

      case [etag, current_etag]
      in [_, nil]
        [decider.initial_state, nil]
      in [nil, _]
        [value, current_etag]
      in [etag, ^etag]
        [value, etag]
      else
        raise WrongExpectedVersion.new(etag, current_etag)
      end
    end

    def save(state, key:, etag: nil)
      new_etag = SecureRandom.hex

      if etag
        store.execute(<<~SQL, key: key, value: state, new_etag: new_etag, etag: etag)
          UPDATE state
          SET value = :value, etag = :new_etag
          WHERE id = :key AND etag = :etag
        SQL
      else
        store.execute(<<~SQL, key: key, value: state, etag: new_etag)
          INSERT INTO state (id, value, etag) VALUES (:key, :value, :etag)
          ON CONFLICT (id) DO NOTHING
        SQL
      end

      if store.changes.zero?
        raise WrongExpectedVersion.new(etag, new_etag)
      end

      new_etag
    end

    private

    attr_reader :store, :decider
  end

  class StateTest < Minitest::Spec
    before do
      @db = SQLite3::Database.new(":memory:")
      @db.execute <<~SQL
        CREATE TABLE state (
          id TEXT PRIMARY KEY,
          value INT,
          etag TEXT
        )
      SQL
    end

    after do
      @db.close
    end

    def repository
      @repository ||= Repository.new(
        store: @db,
        decider: Example
      )
    end

    describe "#call" do
      it "returns decide result" do
        handler = Decider::State.new(
          decider: Example,
          repository: repository
        )

        result, etag = handler.call(:increase, key: "test", etag: nil)
        assert_equal [:increased], result

        result, _etag = handler.call(:decrease, key: "test", etag: etag)
        assert_equal [:decreased], result
      end

      it "stores state" do
        handler = Decider::State.new(
          decider: Example,
          repository: repository
        )

        state, _etag = repository.try_load(key: "test")
        assert_equal 0, state

        _result, etag = handler.call(:increase, key: "test")
        _result, etag = handler.call(:increase, key: "test", etag: etag)

        state, etag = repository.try_load(key: "test", etag: etag)
        assert_equal 2, state

        _result, etag = handler.call(:decrease, key: "test", etag: etag)

        state, _etag = repository.try_load(key: "test", etag: etag)
        assert_equal 1, state
      end

      it "handles race conditions" do
        handler = Decider::State.new(
          decider: Example,
          repository: repository
        )

        threads = Array.new(2) do
          Thread.new do
            Thread.stop
            handler.call(:slow, key: "test", etag: nil)
          rescue WrongExpectedVersion
          end
        end
        sleep 0.1 until threads.all?(&:stop?)
        threads.each(&:wakeup).each(&:join)

        result, _etag = repository.try_load(key: "test")

        assert_equal 1, result
      end
    end
  end
end
