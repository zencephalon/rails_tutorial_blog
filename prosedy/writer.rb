require 'rubygems'
require 'bcrypt'

class WriterManager
    def initialize(prosedy)
        @prosedy = prosedy
        @writer_db = @prosedy.db.collection('writers')
    end

    def create(name, password)
        return nil if @writer_db.find_one({_id: name})

        ps = BCrypt::Engine.generate_salt
        ph = BCrypt::Engine.hash_secret(password, ps)

        writer = {_id: name, ph: ph, ps: ps, dc: 0}
        @writer_db.insert(writer)
        
        return writer
    end

    def login(name, password)
        writer = find_by_name(name)
        (writer && writer.ph == BCrypt::Engine.hash_secret(password, writer.ps)) ? writer : nil
    end

    def inc_draft_c(name)
        @writer_db.find_and_modify(query: {_id: name}, update: {'$inc' => {dc: 1}}, fields: ['dc'], new: true)['dc']
    end
end


