# The Axe-Change Archive

The ways and means to make a copy of everything that's been uploaded to http://axechange.fractalaudio.com/

This probably isn't totally kosher but I worry this archive of settings will go away some day.

## Use

There's a downloader in the `./bin/` directory that will pull down new things since it was last run. It keeps an index that was last seen in the `config.yaml` file in the root of the repository. If you remove it, it downloads things from the very first preset again.

To run the downloader:

    gem install bundler
    bundle install
    bundle exec bin/axechange_downloader

No command line options or anything. It's pretty basic. It expects `curl` to be available on the `PATH` as it uses that for the actual download of the SysEx data files. The downloaded presets and cab files end up in a `./preset` and `./cab` directory respectively.

## Legal Notice

The presets are the work of their respective authors. They are downloaded under the ToS of Axe-Change.
