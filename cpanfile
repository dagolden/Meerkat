requires "Carp" => "0";
requires "DateTime" => "0";
requires "Module::Runtime" => "0";
requires "MongoDB" => "0";
requires "MongoDB::OID" => "0";
requires "Moose" => "2";
requires "Moose::Role" => "2";
requires "MooseX::AttributeShortcuts" => "0";
requires "MooseX::Role::Logger" => "0";
requires "MooseX::Role::MongoDB" => "0.006";
requires "MooseX::Storage" => "0";
requires "MooseX::Storage::Engine" => "0";
requires "MooseX::Types" => "0";
requires "Scalar::Util" => "0";
requires "Syntax::Keyword::Junction" => "0";
requires "Tie::IxHash" => "0";
requires "Try::Tiny" => "0";
requires "Try::Tiny::Retry" => "0.002";
requires "Type::Params" => "0";
requires "Types::Standard" => "0";
requires "aliased" => "0";
requires "namespace::autoclean" => "0";
requires "perl" => "v5.10.0";
requires "strict" => "0";
requires "warnings" => "0";

on 'test' => sub {
  requires "Data::Faker" => "0";
  requires "DateTime::Tiny" => "0";
  requires "ExtUtils::MakeMaker" => "0";
  requires "File::Spec::Functions" => "0";
  requires "List::Util" => "0";
  requires "MooX::Types::MooseLike::Base" => "0";
  requires "Test::Deep" => "0";
  requires "Test::FailWarnings" => "0";
  requires "Test::Fatal" => "0";
  requires "Test::More" => "0";
  requires "Test::Requires" => "0";
  requires "Test::Roo" => "0";
  requires "Test::Roo::Role" => "0";
  requires "Time::HiRes" => "0";
  requires "lib" => "0";
  requires "version" => "0";
};

on 'test' => sub {
  recommends "CPAN::Meta" => "0";
  recommends "CPAN::Meta::Requirements" => "2.120900";
};

on 'configure' => sub {
  requires "ExtUtils::MakeMaker" => "6.17";
};

on 'develop' => sub {
  requires "Dist::Zilla" => "5";
  requires "Dist::Zilla::PluginBundle::DAGOLDEN" => "0.060";
  requires "File::Spec" => "0";
  requires "File::Temp" => "0";
  requires "IO::Handle" => "0";
  requires "IPC::Open3" => "0";
  requires "Pod::Coverage::TrustPod" => "0";
  requires "Test::CPAN::Meta" => "0";
  requires "Test::More" => "0";
  requires "Test::Pod" => "1.41";
  requires "Test::Pod::Coverage" => "1.08";
};
