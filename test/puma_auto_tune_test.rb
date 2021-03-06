require 'test_helper'

class PumaAutoTuneTest < Test::Unit::TestCase

  def teardown
    @puma.cleanup if @puma
  end

  def test_starts
    @puma = PumaRemote.new.spawn
    @puma.wait

    assert @puma.wait %r{PumaAutoTune}
  end

  def test_cannot_drop_below_one
    @puma = PumaRemote.new(ram: 1, puma_workers: 1).spawn
    @puma.wait

    assert @puma.wait %r{cannot have less than one worker}
  end

  def test_reap_workers
    @puma = PumaRemote.new(ram: 1, puma_workers: 5).spawn
    @puma.wait

    assert @puma.wait %r{current_cluster_size=5}
    assert @puma.wait %r{current_cluster_size=4}
    assert @puma.wait %r{current_cluster_size=3}
    assert @puma.wait %r{current_cluster_size=2}
    assert @puma.wait %r{current_cluster_size=1}

    refute_match /max_worker_limit=0/, @puma.log.read
  end

  def test_increment_workers
    @puma = PumaRemote.new(puma_workers: 1, frequency: 1, reap_duration: 1).spawn
    assert @puma.wait %r{current_cluster_size=3}
  end

end
