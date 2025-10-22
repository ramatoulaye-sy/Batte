-- Table des notifications
CREATE TABLE IF NOT EXISTS public.notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  type TEXT DEFAULT 'info' CHECK (type IN ('info', 'success', 'warning', 'error')),
  is_read BOOLEAN DEFAULT FALSE,
  data JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index pour performance
CREATE INDEX idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX idx_notifications_created_at ON public.notifications(created_at DESC);
CREATE INDEX idx_notifications_is_read ON public.notifications(is_read);

-- RLS
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own notifications"
ON public.notifications
FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own notifications"
ON public.notifications
FOR UPDATE
USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own notifications"
ON public.notifications
FOR DELETE
USING (auth.uid() = user_id);

-- Fonction pour compter les notifications non lues
CREATE OR REPLACE FUNCTION public.get_unread_notifications_count(p_user_id UUID)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_count INTEGER;
BEGIN
  SELECT COUNT(*)
  INTO v_count
  FROM public.notifications
  WHERE user_id = p_user_id
  AND is_read = FALSE;
  
  RETURN COALESCE(v_count, 0);
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_unread_notifications_count(UUID) TO authenticated;

