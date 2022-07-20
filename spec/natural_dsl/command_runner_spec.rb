RSpec.describe NaturalDSL::CommandRunner do
  describe "#run" do
    subject { described_class.new(lang.commands[:some_command], vm).run }

    let(:vm) { NaturalDSL::VM.new(lang) }
    let(:execute_block) { proc { |_, *args| 42 } }

    before do
      allow(execute_block).to receive(:call).and_call_original
    end

    shared_context "empty stack" do |expected_primitive|
      context "when stack not contains matching primitive" do
        it "raises error" do
          expect { subject }.to raise_error "Expected #{expected_primitive} but stack was empty"
        end
      end
    end

    context "when command has no expectations" do
      let(:lang) do
        execute_block_closure = execute_block

        NaturalDSL::Lang.define do
          command(:some_command) { execute(&execute_block_closure) }
        end
      end

      it "calls command without arguments" do
        expect(subject).to eq(42)
        expect(execute_block).to have_received(:call).with(vm)
      end

      context "when stack is not empty" do
        before do
          vm.stack << NaturalDSL::Primitives::Token.new(42)
        end

        it "raises StackNotEmpty error" do
          expect { subject }.to raise_error described_class::StackNotEmpty, "unexpected Token after some_command"
        end
      end
    end

    context "when command has expectations" do
      context "when command expects keyword" do
        let(:lang) do
          execute_block_closure = execute_block

          NaturalDSL::Lang.define do
            command(:some_command) do
              keyword :keyword1

              execute(&execute_block_closure)
            end
          end
        end

        include_context "empty stack", "Keyword"

        context "when stack contains matching primitive" do
          before do
            vm.stack << NaturalDSL::Primitives::Keyword.new(:keyword1)
          end

          it "calls command without arguments" do
            expect(subject).to eq(42)
            expect(execute_block).to have_received(:call).with(vm)
          end
        end
      end

      context "when command expects token" do
        let(:lang) do
          execute_block_closure = execute_block

          NaturalDSL::Lang.define do
            command(:some_command) do
              token

              execute(&execute_block_closure)
            end
          end
        end

        include_context "empty stack", "Token"

        context "when stack contains matching primitive" do
          let(:token_something) { NaturalDSL::Primitives::Token.new(:something) }

          before do
            vm.stack << token_something
          end

          it "calls command with token" do
            expect(subject).to eq(42)
            expect(execute_block).to have_received(:call).with(vm, token_something)
          end

          context "when command expects two tokens" do
            let(:lang) do
              execute_block_closure = execute_block

              NaturalDSL::Lang.define do
                command(:some_command) do
                  token
                  token

                  execute(&execute_block_closure)
                end
              end
            end

            let(:token_something_else) { NaturalDSL::Primitives::Token.new(:something_else) }

            before do
              vm.stack << token_something_else
            end

            it "calls command with both tokens" do
              expect(subject).to eq(42)
              expect(execute_block).to have_received(:call).with(vm, token_something_else, token_something)
            end
          end
        end
      end

      context "when command expects value" do
        let(:lang) do
          execute_block_closure = execute_block

          NaturalDSL::Lang.define do
            command(:some_command) do
              value

              execute(&execute_block_closure)
            end
          end
        end

        include_context "empty stack", "Value"

        context "when stack contains matching primitive" do
          let(:value) { NaturalDSL::Primitives::Value.new(42) }

          before do
            vm.stack << value
          end

          it "calls command with token" do
            expect(subject).to eq(42)
            expect(execute_block).to have_received(:call).with(vm, value)
          end

          context "when command expects token and value" do
            let(:lang) do
              execute_block_closure = execute_block

              NaturalDSL::Lang.define do
                command(:some_command) do
                  token
                  value

                  execute(&execute_block_closure)
                end
              end
            end

            let(:token_something) { NaturalDSL::Primitives::Token.new(:something) }

            before do
              vm.stack << token_something
            end

            it "calls command with both tokens" do
              expect(subject).to eq(42)
              expect(execute_block).to have_received(:call).with(vm, token_something, value)
            end
          end
        end
      end
    end
  end
end
