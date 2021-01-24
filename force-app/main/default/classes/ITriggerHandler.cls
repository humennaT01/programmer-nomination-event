public virtual class ITriggerHandler 
{
    public virtual void BeforeInsert(List<SObject> newItems){}
    public virtual void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){}
    public virtual void BeforeDelete(Map<Id, SObject> oldItems){}
    public virtual void AfterInsert(Map<Id, SObject> newItems){}
    public virtual void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){}
    public virtual void AfterDelete(Map<Id, SObject> oldItems){}
    public virtual void AfterUndelete(Map<Id, SObject> oldItems){}
}