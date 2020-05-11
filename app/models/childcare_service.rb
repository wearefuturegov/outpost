class ChildcareService < Service

    def ofsted_pending?
        self.snapshots.last.action === ("ofsted_create" || "ofsted_update")
    end

    scope :ofsted_pending, -> { where(ofsted_pending: true)}


end